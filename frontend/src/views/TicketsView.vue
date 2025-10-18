<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold text-gray-900">Tickets</h1>
      <router-link to="/tickets/new" class="btn-primary">
        Create Ticket
      </router-link>
    </div>

    <!-- Filters -->
    <div class="card mb-6">
      <h2 class="text-lg font-semibold mb-4">Filters</h2>
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div>
          <label class="label">Status</label>
          <select v-model="filters.status" @change="applyFilters" class="input-field">
            <option value="">All Statuses</option>
            <option value="ticket_new">New</option>
            <option value="open">Open</option>
            <option value="pending">Pending</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>
        </div>

        <div>
          <label class="label">Priority</label>
          <select v-model="filters.priority" @change="applyFilters" class="input-field">
            <option value="">All Priorities</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>

        <div>
          <label class="label">Category</label>
          <select v-model="filters.category" @change="applyFilters" class="input-field">
            <option value="">All Categories</option>
            <option value="Technical">Technical</option>
            <option value="Billing">Billing</option>
            <option value="Account">Account</option>
            <option value="General">General</option>
          </select>
        </div>

        <div>
          <label class="label">Search</label>
          <input
            v-model="filters.q"
            @input="debouncedSearch"
            type="text"
            placeholder="Search tickets..."
            class="input-field"
          />
        </div>
      </div>

      <div class="mt-4 flex justify-end">
        <button @click="clearFilters" class="btn-secondary text-sm">
          Clear Filters
        </button>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="ticketsStore.loading" class="text-center py-12">
      <p class="text-gray-500">Loading tickets...</p>
    </div>

    <!-- Error state -->
    <div v-else-if="ticketsStore.error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
      {{ ticketsStore.error }}
    </div>

    <!-- Tickets list -->
    <div v-else-if="ticketsStore.tickets.length > 0" class="space-y-4">
      <div
        v-for="ticket in ticketsStore.tickets"
        :key="ticket.id"
        class="card hover:shadow-lg transition-shadow cursor-pointer"
        @click="router.push(`/tickets/${ticket.id}`)"
      >
        <div class="flex justify-between items-start">
          <div class="flex-1">
            <div class="flex items-center space-x-3 mb-2">
              <span class="text-sm font-mono text-gray-500">{{ ticket.ticket_key }}</span>
              <span :class="`badge badge-${ticket.status}`">
                {{ formatStatus(ticket.status) }}
              </span>
              <span :class="`badge badge-${ticket.priority}`">
                {{ ticket.priority }}
              </span>
            </div>
            <h3 class="text-lg font-semibold text-gray-900 mb-1">{{ ticket.title }}</h3>
            <div class="flex items-center space-x-4 text-sm text-gray-600">
              <span>{{ ticket.category }}</span>
              <span>Created by: {{ ticket.requester.full_name }}</span>
              <span v-if="ticket.assignee">Assigned to: {{ ticket.assignee.full_name }}</span>
              <span v-else class="text-gray-400">Unassigned</span>
            </div>
            <div v-if="ticket.tags.length > 0" class="mt-2 flex flex-wrap gap-2">
              <span
                v-for="tag in ticket.tags"
                :key="tag.id"
                class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium"
                :style="{ backgroundColor: tag.color + '20', color: tag.color }"
              >
                {{ tag.name }}
              </span>
            </div>
          </div>
          <div class="text-right text-sm text-gray-500">
            <p>{{ formatDate(ticket.created_at) }}</p>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="ticketsStore.pagination.total_pages > 1" class="flex justify-center items-center space-x-4 mt-8">
        <button
          @click="changePage(ticketsStore.pagination.current_page - 1)"
          :disabled="ticketsStore.pagination.current_page === 1"
          class="btn-secondary text-sm disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Previous
        </button>
        <span class="text-gray-700">
          Page {{ ticketsStore.pagination.current_page }} of {{ ticketsStore.pagination.total_pages }}
        </span>
        <button
          @click="changePage(ticketsStore.pagination.current_page + 1)"
          :disabled="ticketsStore.pagination.current_page === ticketsStore.pagination.total_pages"
          class="btn-secondary text-sm disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Next
        </button>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="text-center py-12">
      <p class="text-gray-500 mb-4">No tickets found</p>
      <router-link to="/tickets/new" class="btn-primary">
        Create Your First Ticket
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useTicketsStore } from '../stores/tickets'

const router = useRouter()
const ticketsStore = useTicketsStore()

const filters = ref({
  status: '',
  priority: '',
  category: '',
  q: ''
})

let searchTimeout = null

onMounted(() => {
  loadTickets()
})

const loadTickets = async (page = 1) => {
  await ticketsStore.fetchTickets(page)
}

const applyFilters = () => {
  ticketsStore.filters = { ...filters.value }
  loadTickets()
}

const debouncedSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    applyFilters()
  }, 500)
}

const clearFilters = () => {
  filters.value = {
    status: '',
    priority: '',
    category: '',
    q: ''
  }
  ticketsStore.clearFilters()
  loadTickets()
}

const changePage = (page) => {
  loadTickets(page)
}

const formatStatus = (status) => {
  if (status === 'ticket_new') return 'New'
  return status.charAt(0).toUpperCase() + status.slice(1)
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>
