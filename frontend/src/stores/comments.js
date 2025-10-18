import { defineStore } from 'pinia'
import axios from 'axios'

export const useCommentsStore = defineStore('comments', {
  state: () => ({
    comments: [],
    loading: false,
    error: null
  }),

  actions: {
    async fetchComments(ticketId) {
      this.loading = true
      this.error = null

      try {
        const response = await axios.get(`/api/tickets/${ticketId}/comments`)
        this.comments = response.data.comments
        this.loading = false
        return { success: true }
      } catch (error) {
        this.error = error.response?.data?.error || 'Failed to load comments'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    async addComment(ticketId, commentData) {
      this.loading = true
      this.error = null

      try {
        const response = await axios.post(`/api/tickets/${ticketId}/comments`, {
          comment: commentData
        })

        this.comments.push(response.data.comment)
        this.loading = false

        return {
          success: true,
          comment: response.data.comment,
          message: response.data.message
        }
      } catch (error) {
        this.error = error.response?.data?.error || error.response?.data?.errors?.join(', ') || 'Failed to add comment'
        this.loading = false
        return { success: false, error: this.error }
      }
    },

    clearComments() {
      this.comments = []
    }
  }
})
