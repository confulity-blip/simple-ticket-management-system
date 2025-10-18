import { defineStore } from 'pinia'
import axios from 'axios'

export const useUsersStore = defineStore('users', {
  state: () => ({
    agents: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchAgents() {
      this.loading = true
      this.error = null

      try {
        const response = await axios.get('/api/users/agents')
        this.agents = response.data.agents
        this.loading = false
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load agents'
        this.loading = false
        return { success: false, error: this.error }
      }
    }
  }
})
