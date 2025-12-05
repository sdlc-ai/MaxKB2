import useCommonStore from './modules/common'
import useLoginStore from './modules/login'
import useUserStore from './modules/user'
import useFolderStore from './modules/folder'
import useThemeStore from './modules/theme'
import useKnowledgeStore from './modules/knowledge'
import useModelStore from './modules/model'
import usePromptStore from './modules/prompt'
import useApplicationStore from './modules/application'
import useChatUserStore from './modules/chat-user'
import useToolStore from './modules/tool'
import useDatasetStore from './modules/dataset'
import useLogStore from './modules/log'
import useDocumentStore from './modules/document'
import useProblemStore from './modules/problem'
import useParagraphStore from './modules/paragraph'
const useStore = () => ({
  common: useCommonStore(),
  login: useLoginStore(),
  user: useUserStore(),
  folder: useFolderStore(),
  theme: useThemeStore(),
  knowledge: useKnowledgeStore(),
  model: useModelStore(),
  prompt: usePromptStore(),
  application: useApplicationStore(),
  chatUser: useChatUserStore(),
  tool: useToolStore(),
  dataset: useDatasetStore(),
  log: useLogStore(),
  document: useDocumentStore(),
  problem: useProblemStore(),
  paragraph: useParagraphStore(),
})

export default useStore
