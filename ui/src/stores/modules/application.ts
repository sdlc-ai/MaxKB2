import { defineStore } from 'pinia'
import { type Ref } from 'vue'
const useApplicationStore = defineStore('application', {
  state: () => ({
    location: `${window.location.origin}${window.Porsche.chatPrefix ? window.Porsche.chatPrefix : window.Porsche.prefix}/`,
  }),
  actions: {},
})

export default useApplicationStore
