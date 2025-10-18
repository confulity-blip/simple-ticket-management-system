import { defineStore } from 'pinia'
import axios from 'axios'

export const useTicketsStore = defineStore('tickets', {
  state: () => ({
    tickets: [],
    currentTicket: null,
    loading: false,
    error: null,
    filters: {
      status: '',
      priority: '',
      category: '',
      assignee_id: '',
      q: ''
    },
    pagination: {
      current_page: 1,
      total_pages: 1,
      total_count: 0,
      per_page: 25
    }
  }),

  getters: {
    ticketById: (state) => (id) => {
      return state.tickets.find(ticket => ticket.id === parseInt(id))
    }
  },

  actions: {
    async fetchTickets(page = 1) {
      this.loading = true
      this.error = null

      try {
        const params = {
          page,
          per_page: this.pagination.per_page,
          ...this.filters
        }

        // Remove empty filter values
        Object.keys(params).forEach(key => {
          if (params[key] === '' || params[key] === null) {
            delete params[key]
          }
        })

        const response = await axios.get('/api/tickets', { params })

        this.tickets = response.data.tickets
        this.pagination = response.data.meta
        this.loading = false

        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load tickets'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    async fetchTicket(id) {
      this.loading = true
      this.error = null

      try {
        const response = await axios.get(`/api/tickets/${id}`)
        this.currentTicket = response.data.ticket
        this.loading = false
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load ticket'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    async createTicket(ticketData) {
      this.loading = true
      this.error = null

      try {
        const response = await axios.post('/api/tickets', {
          ticket: ticketData
        })

        this.currentTicket = response.data.ticket
        this.loading = false

        return {
          success: true,
          ticket: response.data.ticket,
          message: response.data.message
        }
      } catch (error) {
        this.error = error.response?.data?.errors?.join(', ') || 'Failed to create ticket'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    async updateTicket(id, ticketData) {
      this.loading = true
      this.error = null

      try {
        const response = await axios.patch(`/api/tickets/${id}`, {
          ticket: ticketData
        })

        this.currentTicket = response.data.ticket

        // Update in list if present
        const index = this.tickets.findIndex(t => t.id === id)
        if (index !== -1) {
          this.tickets[index] = response.data.ticket
        }

        this.loading = false
        return {
          success: true,
          ticket: response.data.ticket,
          message: response.data.message
        }
      } catch (error) {
        this.error = error.response?.data?.errors?.join(', ') || 'Failed to update ticket'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    async assignTicket(id, assigneeId) {
      this.loading = true
      this.error = null

      try {
        const response = await axios.post(`/api/tickets/${id}/assign`, {
          assignee_id: assigneeId
        })

        this.currentTicket = response.data.ticket

        // Update in list if present
        const index = this.tickets.findIndex(t => t.id === id)
        if (index !== -1) {
          this.tickets[index] = response.data.ticket
        }

        this.loading = false
        return {
          success: true,
          ticket: response.data.ticket,
          message: response.data.message
        }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to assign ticket'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    setFilter(key, value) {
      this.filters[key] = value
    },

    clearFilters() {
      this.filters = {
        status: '',
        priority: '',
        category: '',
        assignee_id: '',
        q: ''
      }
    }
  }
})
