<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-900 mb-6">Dashboard</h1>

    <!-- Loading state -->
    <div v-if="loading" class="text-center py-12">
      <p class="text-gray-500">Loading dashboard...</p>
    </div>

    <div v-else>
      <!-- Key Metrics -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="card">
          <h3 class="text-sm font-semibold text-gray-600 mb-2">Open Tickets</h3>
          <p class="text-3xl font-bold text-green-600">{{ stats.status_counts?.open || 0 }}</p>
        </div>

        <div class="card">
          <h3 class="text-sm font-semibold text-gray-600 mb-2">Pending Tickets</h3>
          <p class="text-3xl font-bold text-yellow-600">{{ stats.status_counts?.pending || 0 }}</p>
        </div>

        <div class="card">
          <h3 class="text-sm font-semibold text-gray-600 mb-2">New Tickets</h3>
          <p class="text-3xl font-bold text-blue-600">{{ stats.status_counts?.new || 0 }}</p>
        </div>

        <div class="card">
          <h3 class="text-sm font-semibold text-gray-600 mb-2">Resolved Today</h3>
          <p class="text-3xl font-bold text-purple-600">{{ stats.metrics?.resolved_today || 0 }}</p>
        </div>
      </div>

      <!-- Agent-specific metrics -->
      <div v-if="authStore.canAssignTickets" class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="card bg-blue-50 border-blue-200">
          <h3 class="text-sm font-semibold text-blue-700 mb-2">My Assigned</h3>
          <p class="text-3xl font-bold text-blue-600">{{ stats.metrics?.my_assigned || 0 }}</p>
        </div>

        <div class="card bg-orange-50 border-orange-200">
          <h3 class="text-sm font-semibold text-orange-700 mb-2">Unassigned</h3>
          <p class="text-3xl font-bold text-orange-600">{{ stats.metrics?.unassigned || 0 }}</p>
        </div>

        <div class="card bg-gray-50 border-gray-200">
          <h3 class="text-sm font-semibold text-gray-700 mb-2">Avg Response Time</h3>
          <p class="text-3xl font-bold text-gray-600">{{ stats.metrics?.avg_response_time_hours || 0 }}h</p>
        </div>
      </div>

      <!-- Status Breakdown -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div class="card">
          <h2 class="text-xl font-semibold mb-4">Tickets by Status</h2>
          <div class="space-y-3">
            <div v-for="(count, status) in stats.status_counts" :key="status" class="flex justify-between items-center">
              <span class="text-gray-700 capitalize">{{ formatStatus(status) }}</span>
              <span :class="`badge badge-${status}`">{{ count }}</span>
            </div>
          </div>
        </div>

        <div class="card">
          <h2 class="text-xl font-semibold mb-4">Tickets by Priority</h2>
          <div class="space-y-3">
            <div v-for="(count, priority) in stats.priority_counts" :key="priority" class="flex justify-between items-center">
              <span class="text-gray-700 capitalize">{{ priority }}</span>
              <span :class="`badge badge-${priority}`">{{ count }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Category Breakdown -->
      <div class="card mb-8" v-if="stats.category_counts && Object.keys(stats.category_counts).length > 0">
        <h2 class="text-xl font-semibold mb-4">Tickets by Category</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div v-for="(count, category) in stats.category_counts" :key="category" class="text-center p-4 bg-gray-50 rounded-lg">
            <p class="text-2xl font-bold text-primary-600">{{ count }}</p>
            <p class="text-sm text-gray-600 mt-1">{{ category }}</p>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="card">
        <h2 class="text-xl font-semibold mb-4">Quick Actions</h2>
        <div class="flex flex-wrap gap-4">
          <router-link to="/tickets" class="btn-primary">View All Tickets</router-link>
          <router-link to="/tickets/new" class="btn-secondary">Create New Ticket</router-link>
          <router-link to="/tickets?status=open" class="btn-secondary">View Open Tickets</router-link>
          <router-link v-if="authStore.canAssignTickets" to="/tickets?assignee_id=" class="btn-secondary">View Unassigned</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const authStore = useAuthStore()

const stats = ref({})
const loading = ref(true)

onMounted(async () => {
  await fetchDashboardStats()
})

const fetchDashboardStats = async () => {
  loading.value = true
  try {
    const response = await axios.get('/api/analytics/dashboard')
    stats.value = response.data
  } catch (error) {
    console.error('Failed to load dashboard stats:', error)
  } finally {
    loading.value = false
  }
}

const formatStatus = (status) => {
  if (status === 'new') return 'New'
  return status.charAt(0).toUpperCase() + status.slice(1)
}
</script>
