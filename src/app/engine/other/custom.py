import os

import joblib
from sqlalchemy import func, select

from app.db.sql.models.component import Component

from ..base_node import SAVING_DIR, BaseNode, build_save_path
from ..repositories.execution import EnginePersistence
from ..repositories.db import get_sync_session
from ..utils import PayloadBuilder

base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
blueprint_dir = os.path.join(base_dir, "engine", "blueprint")


class Joiner(BaseNode):
    """Joins two datasets using port-based connections."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        ref_1 = in_ports.get("1") or in_ports.get("data_1")
        ref_2 = in_ports.get("2") or in_ports.get("data_2")

        self.data_1 = EnginePersistence.load_port(ref_1, self.project_id) if ref_1 else None
        self.data_2 = EnginePersistence.load_port(ref_2, self.project_id) if ref_2 else None

        err = None
        if self.data_1 is None or self.data_2 is None:
            err = "Failed to load data. Please check the provided port refs."
        elif any(isinstance(i, str) for i in [self.data_1, self.data_2]):
            err = "Failed to load Nodes (data_1, data_2) at least one of them."

        self.payload = self.join(err)
        return self.payload

    def join(self, err=None):
        if err:
            return err
        try:
            joined_data = (self.data_1, self.data_2)
            payload = PayloadBuilder.build_payload(
                "joined_data",
                joined_data,
                "joiner",
                node_type="custom",
                task="join",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error joining data: {e}"


class Splitter(BaseNode):
    """Splits data into two parts.

    Stores port-keyed results: {"0:0": part1, "0:1": part2}.
    """

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        data_ref = in_ports.get("data")
        self.data = EnginePersistence.load_port(data_ref, self.project_id) if data_ref else None

        err = None
        if self.data is None:
            err = "Failed to load data. Please check the provided port ref."
        elif isinstance(self.data, str):
            err = "Failed to load data. Please check the provided ID."

        self.payload = self._build_payload(err)
        return self.payload

    def _build_payload(self, err=None):
        if err:
            return err
        try:
            out1, out2 = self.data

            port_data = {"0:0": out1, "0:1": out2}

            payload = PayloadBuilder.build_payload(
                "data",
                port_data,
                "splitter",
                node_type="custom",
                task="split",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error splitting data: {e}"

    def __str__(self):
        return f"data: {self.payload}"


class NodeTemplateSaver(BaseNode):
    """Saves a node as a reusable template."""

    def __init__(self, **kwargs):
        self.chosen_name = kwargs.pop("name", "")
        self.description = kwargs.pop("description", "")
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        node_ref = in_ports.get("node")
        if node_ref:
            node_id = str(node_ref).split(":")[0]
            success, self.node = EnginePersistence.load_node_meta(int(node_id), project_id=self.project_id)
        else:
            success = False
            self.node = None

        err = None
        if not success:
            err = "Failed to load node. Please check the provided ID."

        self.payload = self.save_template(err)
        return self.payload

    def save_template(self, err=None):
        if err:
            return err

        try:
            node_name = self.chosen_name.replace(" ", "_").lower()

            with get_sync_session() as session:
                max_id = session.execute(select(func.max(Component.id))).scalar() or 0
                last_cid = max_id + 1

                existing = session.execute(
                    select(Component.name).where(Component.name == node_name)
                ).scalar()
                while existing:
                    node_name = f"{node_name}_{last_cid}"
                    existing = session.execute(
                        select(Component.name).where(Component.name == node_name)
                    ).scalar()

                params = self._transform_params(self.node.get("params"))

                new_component = Component(
                    id=last_cid,
                    name=node_name,
                    displayed_name=self.chosen_name,
                    description=self.description,
                    category="Custom",
                    order=6,
                    type="custom",
                    task="template",
                    params=params,
                    inputs=None,
                    outputs=[{"name": "node", "type": "node"}],
                    api_call="/template",
                )
                session.add(new_component)
                session.commit()

            node_content = EnginePersistence.load_data(
                self.node.get("node_id"), project_id=self.project_id
            )
            payload = PayloadBuilder.build_payload(
                "node",
                node_content,
                node_name,
                node_type="custom",
                task="save_template",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
                params=params,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(payload, path=rf"{blueprint_dir}")
            payload.pop("node_data", None)
            return payload
        except Exception as e:
            return f"Error saving node template: {e}"

    @staticmethod
    def _transform_params(params):
        transformed = []
        if params:
            for param_dict in params:
                for key, value in param_dict.items():
                    param_type = (
                        "float"
                        if isinstance(value, float)
                        else (
                            "int"
                            if isinstance(value, int)
                            else ("bool" if isinstance(value, bool) else "str")
                        )
                    )
                    transformed.append(
                        {"name": key, "type": param_type, "default": value}
                    )
        return transformed


class NodeTemplateLoader(BaseNode):
    """Loads a reusable template."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def execute(self):
        in_ports = self.in_ports or {}
        template_ref = in_ports.get("template_id") or self.params.get("template_id")
        if template_ref:
            self.component_id = int(str(template_ref).split(":")[0])
        elif self.component_id:
            self.component_id = int(self.component_id)
        else:
            self.payload = "No template ID provided."
            return self.payload

        self.payload = self.load_template()
        return self.payload

    def load_template(self, err=None):
        if err:
            return err

        try:
            with get_sync_session() as session:
                component = session.execute(
                    select(Component).where(Component.id == self.component_id)
                ).scalar_one_or_none()

            if not component:
                return f"Component with ID {self.component_id} not found."

            node_name = component.name
            files_names = os.listdir(blueprint_dir)

            node_path = None
            for file_name in files_names:
                if file_name.startswith(node_name):
                    node_path = os.path.join(blueprint_dir, file_name)
                    break
            if not node_path:
                return f"Node template with name {node_name} not found."

            node_data = joblib.load(node_path)
            payload = PayloadBuilder.build_payload(
                "node",
                node_data,
                "template",
                node_type="custom",
                task="load_template",
                node_id=self.node_id,
                project_id=self.project_id,
                component_id=self.component_id,
                in_ports=self.in_ports,
                out_ports=self.out_ports,
                displayed_name=self.displayed_name,
                location_x=self.location_x,
                location_y=self.location_y,
            )

            EnginePersistence.save_result(payload, path=build_save_path(SAVING_DIR, self.project_id, self.workflow_id))
            payload.pop("node_data", None)

            return payload

        except FileNotFoundError:
            return f"Node template with ID {self.component_id} not found."
        except Exception as e:
            return f"Error loading node template: {e}"
