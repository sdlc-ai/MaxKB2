# coding=utf-8

from application.flow.i_step_node import KnowledgeFlowParamsSerializer
from application.flow.loop_workflow_manage import LoopWorkflowManage


class KnowledgeLoopWorkflowManage(LoopWorkflowManage):
    def get_params_serializer_class(self):
        return KnowledgeFlowParamsSerializer
