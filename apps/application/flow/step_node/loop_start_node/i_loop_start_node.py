# coding=utf-8

from application.flow.common import WorkflowMode
from application.flow.i_step_node import INode, NodeResult


class ILoopStarNode(INode):
    type = 'loop-start-node'
    support = [WorkflowMode.APPLICATION_LOOP, WorkflowMode.KNOWLEDGE_LOOP]

    def _run(self):
        return self.execute(**self.flow_params_serializer.data)

    def execute(self, **kwargs) -> NodeResult:
        pass
