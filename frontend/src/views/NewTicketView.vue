<template>
  <div>
    <div class="mb-6">
      <button @click="router.back()" class="text-primary-600 hover:text-primary-700 mb-4">
        ← Back to Tickets
      </button>
      <h1 class="text-3xl font-bold text-gray-900">Create New Ticket</h1>
    </div>

    <div class="max-w-2xl">
      <form @submit.prevent="handleSubmit" class="card space-y-6">
        <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {{ error }}
        </div>

        <div>
          <label for="title" class="label">Title *</label>
          <input
            id="title"
            v-model="formData.title"
            type="text"
            required
            class="input-field"
            placeholder="Brief summary of your issue"
          />
        </div>

        <div>
          <label for="description" class="label">Description *</label>
          <textarea
            id="description"
            v-model="formData.description"
            rows="6"
            required
            class="input-field"
            placeholder="Provide detailed information about your issue..."
          ></textarea>
        </div>

        <div>
          <label for="category" class="label">Category *</label>
          <select id="category" v-model="formData.category" required class="input-field">
            <option value="">Select a category</option>
            <option value="Technical">Technical</option>
            <option value="Billing">Billing</option>
            <option value="Account">Account</option>
            <option value="General">General</option>
          </select>
        </div>

        <div>
          <label for="priority" class="label">Priority *</label>
          <select id="priority" v-model="formData.priority" required class="input-field">
            <option value="">Select priority</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>

        <div class="flex space-x-4">
          <button type="submit" :disabled="loading" class="btn-primary">
            {{ loading ? 'Creating...' : 'Create Ticket' }}
          </button>
          <button type="button" @click="router.back()" class="btn-secondary">
            Cancel
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useTicketsStore } from '../stores/tickets'

const router = useRouter()
const ticketsStore = useTicketsStore()

const formData = ref({
  title: '',
  description: '',
  category: '',
  priority: 'medium'
})

const loading = ref(false)
const error = ref(null)

const handleSubmit = async () => {
  loading.value = true
  error.value = null

  const result = await ticketsStore.createTicket(formData.value)

  if (result.success) {
    router.push(`/tickets/${result.ticket.id}`)
  } else {
    error.value = result.error
    loading.value = false
  }
}
</script>
