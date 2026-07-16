"""Tests for app.engine.dag — pure DAG helper functions."""

from unittest.mock import MagicMock

from app.engine.dag import (
    build_dag,
    compute_node_hash,
    extract_node_ids,
    find_downstream,
    topological_levels,
    topological_sort,
)


class TestExtractNodeIds:
    def test_empty_ports(self):
        assert extract_node_ids([]) == []
        assert extract_node_ids(None) == []

    def test_dict_ports_with_node_id(self):
        ports = [{"node_id": 10}, {"node_id": 20}]
        assert extract_node_ids(ports) == [10, 20]

    def test_dict_ports_with_id(self):
        ports = [{"id": 10}, {"id": 20}]
        assert extract_node_ids(ports) == [10, 20]

    def test_int_ports(self):
        ports = [10, 20]
        assert extract_node_ids(ports) == [10, 20]

    def test_mixed_ports(self):
        ports = [{"node_id": 10}, 20, {"id": 30}]
        assert extract_node_ids(ports) == [10, 20, 30]

    def test_dict_port_without_id(self):
        ports = [{"name": "test"}]
        assert extract_node_ids(ports) == []

    def test_float_ports(self):
        ports = [10.0, 20.0]
        assert extract_node_ids(ports) == [10, 20]


class TestBuildDag:
    def _make_node(self, node_id, out_ports):
        node = MagicMock()
        node.id = node_id
        node.out_ports = out_ports
        return node

    def test_simple_chain(self):
        n1 = self._make_node(1, [{"node_id": 2}])
        n2 = self._make_node(2, [{"node_id": 3}])
        n3 = self._make_node(3, [])
        dag = build_dag([n1, n2, n3])
        assert dag == {1: {2}, 2: {3}, 3: set()}

    def test_diamond(self):
        n1 = self._make_node(1, [{"node_id": 2}, {"node_id": 3}])
        n2 = self._make_node(2, [{"node_id": 4}])
        n3 = self._make_node(3, [{"node_id": 4}])
        n4 = self._make_node(4, [])
        dag = build_dag([n1, n2, n3, n4])
        assert dag[1] == {2, 3}
        assert dag[2] == {4}
        assert dag[3] == {4}
        assert dag[4] == set()

    def test_self_reference_ignored(self):
        n1 = self._make_node(1, [{"node_id": 1}])
        dag = build_dag([n1])
        assert dag[1] == set()

    def test_external_reference_ignored(self):
        n1 = self._make_node(1, [{"node_id": 99}])
        dag = build_dag([n1])
        assert dag[1] == set()


class TestFindDownstream:
    def test_linear_chain(self):
        dag = {1: {2}, 2: {3}, 3: set()}
        assert find_downstream(dag, [1]) == {1, 2, 3}

    def test_diamond(self):
        dag = {1: {2, 3}, 2: {4}, 3: {4}, 4: set()}
        assert find_downstream(dag, [1]) == {1, 2, 3, 4}

    def test_partial_downstream(self):
        dag = {1: {2}, 2: {3}, 3: set()}
        assert find_downstream(dag, [2]) == {2, 3}

    def test_no_downstream(self):
        dag = {1: {2}, 2: set()}
        assert find_downstream(dag, []) == set()


class TestTopologicalSort:
    def test_linear_chain(self):
        dag = {1: {2}, 2: {3}, 3: set()}
        result = topological_sort(dag, {1, 2, 3})
        assert result.index(1) < result.index(2) < result.index(3)

    def test_diamond(self):
        dag = {1: {2, 3}, 2: {4}, 3: {4}, 4: set()}
        result = topological_sort(dag, {1, 2, 3, 4})
        assert result.index(1) < result.index(2)
        assert result.index(1) < result.index(3)
        assert result.index(2) < result.index(4)
        assert result.index(3) < result.index(4)

    def test_independent_nodes(self):
        dag = {1: set(), 2: set(), 3: set()}
        result = topological_sort(dag, {1, 2, 3})
        assert set(result) == {1, 2, 3}

    def test_cycle_detection(self):
        dag = {1: {2}, 2: {1}}
        result = topological_sort(dag, {1, 2})
        assert set(result) == {1, 2}


class TestTopologicalLevels:
    def test_linear_chain(self):
        dag = {1: {2}, 2: {3}, 3: set()}
        levels = topological_levels(dag, {1, 2, 3})
        assert levels == [[1], [2], [3]]

    def test_diamond(self):
        dag = {1: {2, 3}, 2: {4}, 3: {4}, 4: set()}
        levels = topological_levels(dag, {1, 2, 3, 4})
        assert levels[0] == [1]
        assert set(levels[1]) == {2, 3}
        assert levels[2] == [4]

    def test_independent_nodes(self):
        dag = {1: set(), 2: set(), 3: set()}
        levels = topological_levels(dag, {1, 2, 3})
        assert len(levels) == 1
        assert set(levels[0]) == {1, 2, 3}

    def test_wide_dag(self):
        dag = {1: {2}, 2: {3, 4}, 3: {5}, 4: {5}, 5: set()}
        levels = topological_levels(dag, {1, 2, 3, 4, 5})
        assert levels[0] == [1]
        assert levels[1] == [2]
        assert set(levels[2]) == {3, 4}
        assert levels[3] == [5]

    def test_empty_dag(self):
        levels = topological_levels({}, set())
        assert levels == []


class TestComputeNodeHash:
    def _hash(self, params=None, parent_hashes=None, **overrides):
        """Helper to call the current compute_node_hash signature."""
        return compute_node_hash(
            node_name=overrides.get("node_name", "test_node"),
            params=params or {},
            out_ports=overrides.get("out_ports", []),
            in_ports=overrides.get("in_ports", []),
            parent_hashes=parent_hashes or {},
        )

    def test_deterministic(self):
        h1 = self._hash({"a": 1}, {10: "hash1"})
        h2 = self._hash({"a": 1}, {10: "hash1"})
        assert h1 == h2

    def test_different_params(self):
        h1 = self._hash({"a": 1})
        h2 = self._hash({"a": 2})
        assert h1 != h2

    def test_different_parents(self):
        h1 = self._hash(
            in_ports={"Data": "10:0:0"},
            parent_hashes={10: "hash1"},
        )
        h2 = self._hash(
            in_ports={"Data": "10:0:0"},
            parent_hashes={10: "hash2"},
        )
        assert h1 != h2

    def test_different_type(self):
        h1 = self._hash({"a": 1}, node_name="type_a")
        h2 = self._hash({"a": 1}, node_name="type_b")
        assert h1 != h2

    def test_different_topology(self):
        h1 = self._hash(in_ports={"Data": "1:0:0"})
        h2 = self._hash(in_ports={"Data": "2:0:0"})
        assert h1 != h2

    def test_returns_sha256(self):
        h = self._hash()
        assert len(h) == 64
