import { defineStore } from 'pinia'
import axios from 'axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('auth_token') || null,
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
        this.token = response.data.token

        // Store token in localStorage
        localStorage.setItem('auth_token', response.data.token)

        // Set token in axios default headers
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.token}`

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
      } catch (error) {
        // Ignore errors on logout
      } finally {
        this.user = null
        this.token = null
        this.initialized = false

        // Remove token from localStorage and axios headers
        localStorage.removeItem('auth_token')
        delete axios.defaults.headers.common['Authorization']

        return { success: true }
      }
    },

    async checkAuth() {
      try {
        // If we have a token, set it in axios headers
        if (this.token) {
          axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`
        }

        const response = await axios.get('/api/me')
        this.user = response.data.user
        this.initialized = true
        return { success: true }
      } catch (error) {
        // Token is invalid, clear it
        this.user = null
        this.token = null
        this.initialized = true
        localStorage.removeItem('auth_token')
        delete axios.defaults.headers.common['Authorization']
        return { success: false }
      }
    },

    clearAuth() {
      this.user = null
      this.token = null
      this.initialized = false
      localStorage.removeItem('auth_token')
      delete axios.defaults.headers.common['Authorization']
    }
  }
})
