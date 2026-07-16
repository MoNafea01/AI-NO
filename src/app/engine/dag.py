"""Pure helper functions for DAG-based workflow execution.

These are shared between the async ``WorkflowExecutor`` and the Celery task.
No database access — pure data transformations only.
"""

import hashlib
import json
import logging
from collections import deque

logger = logging.getLogger(__name__)


def extract_node_ids(ports) -> list[int]:
    """Extract upstream node IDs from a port dict or legacy list format."""
    if not ports:
        return []
    if isinstance(ports, dict):
        ids = []
        for port_ref in ports.values():
            parts = str(port_ref).split(":")
            if parts:
                try:
                    ids.append(int(parts[0]))
                except (ValueError, TypeError):
                    pass
        return ids
    # Legacy list format
    ids = []
    for p in ports:
        if isinstance(p, dict):
            nid = p.get("node_id") or p.get("id")
            if nid is not None:
                ids.append(int(nid))
        elif isinstance(p, int | float):
            ids.append(int(p))
    return ids


def build_dag(nodes: list) -> dict[int, set[int]]:
    existing = {n.id for n in nodes}
    dag: dict[int, set[int]] = {n.id: set() for n in nodes}
    for n in nodes:
        for child_id in extract_node_ids(n.out_ports):
            if child_id in existing and child_id != n.id:
                dag[n.id].add(child_id)
    return dag


def find_downstream(dag: dict[int, set[int]], start_ids: list[int]) -> set[int]:
    visited = set(start_ids)
    queue = deque(start_ids)
    while queue:
        nid = queue.popleft()
        for child in dag.get(nid, set()):
            if child not in visited:
                visited.add(child)
                queue.append(child)
    return visited


def topological_sort(dag: dict[int, set[int]], subset: set[int]) -> list[int]:
    in_degree: dict[int, int] = {nid: 0 for nid in subset}
    for src in subset:
        for dst in dag.get(src, set()):
            if dst in subset:
                in_degree[dst] = in_degree.get(dst, 0) + 1
    queue = deque([nid for nid, deg in in_degree.items() if deg == 0])
    ordered = []
    while queue:
        nid = queue.popleft()
        ordered.append(nid)
        for dst in dag.get(nid, set()):
            if dst in subset:
                in_degree[dst] -= 1
                if in_degree[dst] == 0:
                    queue.append(dst)
    if len(ordered) != len(subset):
        missing = subset - set(ordered)
        logger.warning("Cycle detected among %s — appending remaining", missing)
        ordered.extend(missing - set(ordered))
    return ordered


def topological_levels(dag: dict[int, set[int]], subset: set[int]) -> list[list[int]]:
    """Return nodes grouped by topological depth for parallel execution.

    Each inner list is a "rank level" — all nodes whose predecessors have
    already completed.  Nodes within the same level can run concurrently.
    """
    in_degree: dict[int, int] = {nid: 0 for nid in subset}
    for src in subset:
        for dst in dag.get(src, set()):
            if dst in subset:
                in_degree[dst] += 1

    levels: list[list[int]] = []
    current = [nid for nid, deg in in_degree.items() if deg == 0]

    while current:
        levels.append(current)
        next_level = []
        for nid in current:
            for dst in dag.get(nid, set()):
                if dst in subset:
                    in_degree[dst] -= 1
                    if in_degree[dst] == 0:
                        next_level.append(dst)
        current = next_level

    remaining = [nid for nid in subset if in_degree.get(nid, 0) > 0]
    if remaining:
        logger.warning("Cycle detected among %s — executing as final level", remaining)
        levels.append(remaining)

    return levels


def compute_node_hash(
    node_type: str,
    task: str,
    params: dict,
    out_ports: dict,
    in_ports: dict,
    parent_hashes: dict[int, str],
) -> str:
    """Compute content-addressable hash for a node's execution inputs.

    Includes everything that affects output: type, task, params,
    topology (ports), and parent content hashes.  Changing any of these
    produces a different hash, invalidating the cache for this node and
    all its downstream dependents.
    """
    parent_hash_list = []
    for port_ref in (in_ports or {}).values():
        parts = str(port_ref).split(":")
        if parts:
            try:
                pid = int(parts[0])
                if pid in parent_hashes:
                    parent_hash_list.append(parent_hashes[pid])
            except (ValueError, TypeError):
                pass
    parent_hash_list.sort()

    content = {
        "type": node_type,
        "task": task,
        "params": params or {},
        "out_ports": out_ports or {},
        "in_ports": in_ports or {},
        "parent_hashes": parent_hash_list,
    }
    content_json = json.dumps(content, sort_keys=True, ensure_ascii=False, default=str)
    return hashlib.sha256(content_json.encode("utf-8")).hexdigest()


__all__ = [
    "build_dag", "extract_node_ids", "find_downstream",
    "topological_sort", "topological_levels", "compute_node_hash",
]
