# coding=utf-8

from application.flow.common import WorkflowMode
from application.flow.i_step_node import INode, NodeResult


class IStarNode(INode):
    type = 'start-node'
    support = [WorkflowMode.APPLICATION]

    def _run(self):
        return self.execute(**self.flow_params_serializer.data)

    def execute(self, question, **kwargs) -> NodeResult:
        pass
