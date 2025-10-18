<template>
  <div>
    <div class="mb-6">
      <button @click="router.back()" class="text-primary-600 hover:text-primary-700 mb-4">
        ← Back to Tickets
      </button>
    </div>

    <!-- Loading state -->
    <div v-if="ticketsStore.loading && !ticketsStore.currentTicket" class="text-center py-12">
      <p class="text-gray-500">Loading ticket...</p>
    </div>

    <!-- Error state -->
    <div v-else-if="ticketsStore.error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
      {{ ticketsStore.error }}
    </div>

    <!-- Ticket details -->
    <div v-else-if="ticketsStore.currentTicket">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Main content -->
        <div class="lg:col-span-2 space-y-6">
          <!-- Ticket header -->
          <div class="card">
            <div class="flex items-center space-x-3 mb-3">
              <span class="text-lg font-mono text-gray-500">{{ ticketsStore.currentTicket.ticket_key }}</span>
              <span :class="`badge badge-${ticketsStore.currentTicket.status}`">
                {{ formatStatus(ticketsStore.currentTicket.status) }}
              </span>
              <span :class="`badge badge-${ticketsStore.currentTicket.priority}`">
                {{ ticketsStore.currentTicket.priority }}
              </span>
            </div>
            <h1 class="text-2xl font-bold text-gray-900 mb-4">{{ ticketsStore.currentTicket.title }}</h1>
            <div class="prose max-w-none text-gray-700">
              {{ ticketsStore.currentTicket.description }}
            </div>
          </div>

          <!-- Comments section -->
          <div class="card">
            <h2 class="text-xl font-semibold mb-4">Comments ({{ commentsStore.comments.length }})</h2>

            <!-- Add comment form -->
            <form @submit.prevent="handleAddComment" class="mb-6">
              <div class="mb-3">
                <label class="label">Add a comment</label>
                <textarea
                  v-model="newComment.body"
                  rows="4"
                  class="input-field"
                  placeholder="Write your comment here..."
                  required
                ></textarea>
              </div>

              <div v-if="authStore.canCreateInternalNotes" class="mb-3">
                <label class="flex items-center space-x-2 cursor-pointer">
                  <input
                    v-model="newComment.isInternal"
                    type="checkbox"
                    class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                  />
                  <span class="text-sm text-gray-700">Internal note (only visible to agents and admins)</span>
                </label>
              </div>

              <div v-if="commentError" class="mb-3 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                {{ commentError }}
              </div>

              <button type="submit" :disabled="commentsStore.loading" class="btn-primary">
                {{ commentsStore.loading ? 'Adding...' : 'Add Comment' }}
              </button>
            </form>

            <!-- Comments list -->
            <div v-if="commentsStore.loading && commentsStore.comments.length === 0" class="text-center py-6">
              <p class="text-gray-500">Loading comments...</p>
            </div>

            <div v-else-if="commentsStore.comments.length > 0" class="space-y-4">
              <div
                v-for="comment in commentsStore.comments"
                :key="comment.id"
                class="border border-gray-200 rounded-lg p-4"
                :class="comment.public ? 'bg-white' : 'bg-yellow-50 border-yellow-200'"
              >
                <div class="flex justify-between items-start mb-2">
                  <div class="flex items-center space-x-2">
                    <span class="font-semibold text-gray-900">{{ comment.author.full_name }}</span>
                    <span class="text-xs text-gray-500">({{ comment.author.role }})</span>
                    <span v-if="!comment.public" class="badge badge-pending text-xs">Internal Note</span>
                  </div>
                  <span class="text-sm text-gray-500">{{ formatDate(comment.created_at) }}</span>
                </div>
                <p class="text-gray-700 whitespace-pre-wrap">{{ comment.body }}</p>
              </div>
            </div>

            <div v-else class="text-center py-6">
              <p class="text-gray-500">No comments yet</p>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-6">
          <!-- Ticket properties -->
          <div class="card">
            <h3 class="font-semibold text-gray-900 mb-4">Ticket Details</h3>
            <dl class="space-y-3">
              <div>
                <dt class="text-sm text-gray-600">Category</dt>
                <dd class="text-sm font-medium text-gray-900">{{ ticketsStore.currentTicket.category }}</dd>
              </div>
              <div v-if="ticketsStore.currentTicket.subcategory">
                <dt class="text-sm text-gray-600">Subcategory</dt>
                <dd class="text-sm font-medium text-gray-900">{{ ticketsStore.currentTicket.subcategory }}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-600">Created by</dt>
                <dd class="text-sm font-medium text-gray-900">{{ ticketsStore.currentTicket.requester.full_name }}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-600">Assigned to</dt>
                <dd class="text-sm font-medium text-gray-900">
                  {{ ticketsStore.currentTicket.assignee?.full_name || 'Unassigned' }}
                </dd>
              </div>
              <div>
                <dt class="text-sm text-gray-600">Created</dt>
                <dd class="text-sm font-medium text-gray-900">{{ formatDate(ticketsStore.currentTicket.created_at) }}</dd>
              </div>
              <div>
                <dt class="text-sm text-gray-600">Last updated</dt>
                <dd class="text-sm font-medium text-gray-900">{{ formatDate(ticketsStore.currentTicket.updated_at) }}</dd>
              </div>
            </dl>
          </div>

          <!-- Tags -->
          <div v-if="ticketsStore.currentTicket.tags.length > 0" class="card">
            <h3 class="font-semibold text-gray-900 mb-3">Tags</h3>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="tag in ticketsStore.currentTicket.tags"
                :key="tag.id"
                class="inline-flex items-center px-2.5 py-0.5 rounded text-xs font-medium"
                :style="{ backgroundColor: tag.color + '20', color: tag.color }"
              >
                {{ tag.name }}
              </span>
            </div>
          </div>

          <!-- Actions (for agents/admins) -->
          <div v-if="authStore.canAssignTickets" class="card">
            <h3 class="font-semibold text-gray-900 mb-3">Actions</h3>
            <div class="space-y-2">
              <button @click="showStatusModal = true" class="btn-secondary w-full text-sm">Change Status</button>
              <button @click="showReassignModal = true" class="btn-secondary w-full text-sm">Reassign</button>
              <button @click="showEditModal = true" class="btn-secondary w-full text-sm">Edit Ticket</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Change Status Modal -->
    <div v-if="showStatusModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="showStatusModal = false">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4" @click.stop>
        <h3 class="text-lg font-semibold mb-4">Change Ticket Status</h3>
        <div class="mb-4">
          <label class="label">New Status</label>
          <select v-model="newStatus" class="input-field">
            <option value="ticket_new">New</option>
            <option value="open">Open</option>
            <option value="pending">Pending</option>
            <option value="resolved">Resolved</option>
            <option value="closed">Closed</option>
          </select>
        </div>
        <div v-if="statusError" class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
          {{ statusError }}
        </div>
        <div class="flex space-x-3">
          <button @click="handleStatusChange" :disabled="updatingStatus" class="btn-primary">
            {{ updatingStatus ? 'Updating...' : 'Update Status' }}
          </button>
          <button @click="showStatusModal = false" class="btn-secondary">Cancel</button>
        </div>
      </div>
    </div>

    <!-- Reassign Modal -->
    <div v-if="showReassignModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="showReassignModal = false">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4" @click.stop>
        <h3 class="text-lg font-semibold mb-4">Reassign Ticket</h3>
        <div class="mb-4">
          <label class="label">Assign to Agent</label>
          <select v-model="newAssigneeId" class="input-field">
            <option value="">Unassigned</option>
            <option v-for="agent in usersStore.agents" :key="agent.id" :value="agent.id">
              {{ agent.full_name }} ({{ agent.role }})
            </option>
          </select>
        </div>
        <div v-if="reassignError" class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
          {{ reassignError }}
        </div>
        <div class="flex space-x-3">
          <button @click="handleReassign" :disabled="reassigning" class="btn-primary">
            {{ reassigning ? 'Reassigning...' : 'Reassign' }}
          </button>
          <button @click="showReassignModal = false" class="btn-secondary">Cancel</button>
        </div>
      </div>
    </div>

    <!-- Edit Ticket Modal -->
    <div v-if="showEditModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 overflow-y-auto" @click="showEditModal = false">
      <div class="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 my-8" @click.stop>
        <h3 class="text-lg font-semibold mb-4">Edit Ticket</h3>
        <form @submit.prevent="handleEdit" class="space-y-4">
          <div>
            <label class="label">Title</label>
            <input v-model="editForm.title" type="text" required class="input-field" />
          </div>
          <div>
            <label class="label">Description</label>
            <textarea v-model="editForm.description" rows="4" required class="input-field"></textarea>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="label">Priority</label>
              <select v-model="editForm.priority" required class="input-field">
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
                <option value="urgent">Urgent</option>
              </select>
            </div>
            <div>
              <label class="label">Category</label>
              <select v-model="editForm.category" required class="input-field">
                <option value="Technical">Technical</option>
                <option value="Billing">Billing</option>
                <option value="Account">Account</option>
                <option value="General">General</option>
              </select>
            </div>
          </div>
          <div v-if="editError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
            {{ editError }}
          </div>
          <div class="flex space-x-3">
            <button type="submit" :disabled="editing" class="btn-primary">
              {{ editing ? 'Saving...' : 'Save Changes' }}
            </button>
            <button type="button" @click="showEditModal = false" class="btn-secondary">Cancel</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useTicketsStore } from '../stores/tickets'
import { useCommentsStore } from '../stores/comments'
import { useAuthStore } from '../stores/auth'
import { useUsersStore } from '../stores/users'

const router = useRouter()
const route = useRoute()
const ticketsStore = useTicketsStore()
const commentsStore = useCommentsStore()
const authStore = useAuthStore()
const usersStore = useUsersStore()

const newComment = ref({
  body: '',
  isInternal: false
})

const commentError = ref(null)

// Modal states
const showStatusModal = ref(false)
const showReassignModal = ref(false)
const showEditModal = ref(false)

// Status change
const newStatus = ref('')
const updatingStatus = ref(false)
const statusError = ref(null)

// Reassign
const newAssigneeId = ref('')
const reassigning = ref(false)
const reassignError = ref(null)

// Edit form
const editForm = ref({
  title: '',
  description: '',
  priority: '',
  category: ''
})
const editing = ref(false)
const editError = ref(null)

const ticketId = route.params.id

onMounted(async () => {
  await ticketsStore.fetchTicket(ticketId)
  await commentsStore.fetchComments(ticketId)

  // Fetch agents for reassignment dropdown
  if (authStore.canAssignTickets) {
    await usersStore.fetchAgents()
  }

  // Initialize form values
  if (ticketsStore.currentTicket) {
    newStatus.value = ticketsStore.currentTicket.status
    newAssigneeId.value = ticketsStore.currentTicket.assignee?.id || ''
    editForm.value = {
      title: ticketsStore.currentTicket.title,
      description: ticketsStore.currentTicket.description,
      priority: ticketsStore.currentTicket.priority,
      category: ticketsStore.currentTicket.category
    }
  }
})

const handleAddComment = async () => {
  commentError.value = null

  const commentData = {
    body: newComment.value.body,
    public: !newComment.value.isInternal
  }

  const result = await commentsStore.addComment(ticketId, commentData)

  if (result.success) {
    newComment.value = {
      body: '',
      isInternal: false
    }
  } else {
    commentError.value = result.error
  }
}

const handleStatusChange = async () => {
  updatingStatus.value = true
  statusError.value = null

  const result = await ticketsStore.updateTicket(ticketId, { status: newStatus.value })

  if (result.success) {
    showStatusModal.value = false
  } else {
    statusError.value = result.error
  }

  updatingStatus.value = false
}

const handleReassign = async () => {
  if (!newAssigneeId.value) {
    reassignError.value = 'Please select an agent'
    return
  }

  reassigning.value = true
  reassignError.value = null

  const result = await ticketsStore.assignTicket(ticketId, parseInt(newAssigneeId.value))

  if (result.success) {
    showReassignModal.value = false
  } else {
    reassignError.value = result.error
  }

  reassigning.value = false
}

const handleEdit = async () => {
  editing.value = true
  editError.value = null

  const result = await ticketsStore.updateTicket(ticketId, editForm.value)

  if (result.success) {
    showEditModal.value = false
  } else {
    editError.value = result.error
  }

  editing.value = false
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
