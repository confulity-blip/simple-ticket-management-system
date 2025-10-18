import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    initialized: false
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
    isAdmin: (state) => state.user?.role === 'admin',
    isAgent: (state) => state.user?.role === 'agent',
    isCustomer: (state) => state.user?.role === 'customer',
    canAssignTickets: (state) => state.user?.role === 'admin' || state.user?.role === 'agent',
    canCreateInternalNotes: (state) => state.user?.role === 'admin' || state.user?.role === 'agent'
  },

  actions: {
    async login(email, password) {
      try {
        const response = await axios.post('/api/sessions', {
          email,
          password
        })

        this.user = response.data.user
        this.initialized = true
        return { success: true, message: response.data.message }
      } catch (error) {
        return {
          success: false,
          error: error.response?.data?.error || 'Login failed'
        }
      }
    },

    async logout() {
      try {
        await axios.delete('/api/sessions')
        this.user = null
        this.initialized = false
        return { success: true }
      } catch (error) {
        return {
          success: false,
          error: error.response?.data?.error || 'Logout failed'
        }
      }
    },

    async checkAuth() {
      try {
        const response = await axios.get('/api/me')
        this.user = response.data.user
        this.initialized = true
        return { success: true }
      } catch (error) {
        this.user = null
        this.initialized = true
        return { success: false }
      }
    },

    clearAuth() {
      this.user = null
      this.initialized = false
    }
  }
})
