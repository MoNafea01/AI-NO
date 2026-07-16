"""Tests for app.engine.schemas — NodePayload, NodeContext."""


from app.engine.schemas import NodeContext, NodePayload


class TestNodePayload:
    def test_required_fields(self):
        payload = NodePayload(message="test", node_name="node1")
        assert payload.message == "test"
        assert payload.node_name == "node1"

    def test_defaults(self):
        payload = NodePayload(message="test", node_name="n")
        assert payload.task == "general"
        assert payload.node_type == "general"
        assert payload.params == {}
        assert payload.input_ports == []
        assert payload.output_ports == []
        assert payload.children == []
        assert payload.parent == []

    def test_node_id_generated(self):
        p1 = NodePayload(message="a", node_name="n")
        p2 = NodePayload(message="a", node_name="n")
        assert p1.node_id != p2.node_id

    def test_custom_fields(self):
        payload = NodePayload(
            message="test",
            node_name="n",
            task="fit_model",
            node_type="fitter",
            params={"lr": 0.01},
            project_id=42,
            workflow_id=7,
            component_id="comp1",
        )
        assert payload.task == "fit_model"
        assert payload.project_id == 42
        assert payload.workflow_id == 7
        assert payload.component_id == "comp1"
        assert payload.params == {"lr": 0.01}

    def test_model_dump_excludes_none(self):
        payload = NodePayload(message="test", node_name="n")
        dumped = payload.model_dump(exclude_none=True)
        assert "project_id" not in dumped
        assert "workflow_id" not in dumped

    def test_model_dump_with_values(self):
        payload = NodePayload(message="test", node_name="n", project_id=1)
        dumped = payload.model_dump(exclude_none=True)
        assert dumped["project_id"] == 1


class TestNodeContext:
    def test_defaults(self):
        ctx = NodeContext()
        assert ctx.project_id is None
        assert ctx.workflow_id is None
        assert ctx.node_id is None
        assert ctx.input_ports == []
        assert ctx.output_ports == []

    def test_custom_values(self):
        ctx = NodeContext(project_id=1, workflow_id=2, node_id=3, node_name="test")
        assert ctx.project_id == 1
        assert ctx.workflow_id == 2
        assert ctx.node_id == 3
        assert ctx.node_name == "test"
