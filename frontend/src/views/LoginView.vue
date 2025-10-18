<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Support Desk
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Sign in to manage your tickets
        </p>
      </div>

      <form class="mt-8 space-y-6 card" @submit.prevent="handleLogin">
        <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {{ error }}
        </div>

        <div class="space-y-4">
          <div>
            <label for="email" class="label">Email address</label>
            <input
              id="email"
              v-model="email"
              type="email"
              required
              class="input-field"
              placeholder="your.email@example.com"
            />
          </div>

          <div>
            <label for="password" class="label">Password</label>
            <input
              id="password"
              v-model="password"
              type="password"
              required
              class="input-field"
              placeholder="Enter your password"
            />
          </div>
        </div>

        <div>
          <button
            type="submit"
            :disabled="loading"
            class="btn-primary w-full"
          >
            {{ loading ? 'Signing in...' : 'Sign in' }}
          </button>
        </div>

        <div class="text-sm text-gray-600 mt-4 p-4 bg-blue-50 rounded-lg">
          <p class="font-semibold mb-2">Test credentials:</p>
          <p><strong>Admin:</strong> admin@supportdesk.com / password123</p>
          <p><strong>Agent:</strong> sarah.johnson@supportdesk.com / password123</p>
          <p><strong>Customer:</strong> john.doe@example.com / password123</p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref(null)

const handleLogin = async () => {
  loading.value = true
  error.value = null

  const result = await authStore.login(email.value, password.value)

  if (result.success) {
    router.push({ name: 'Tickets' })
  } else {
    error.value = result.error
  }

  loading.value = false
}
</script>
