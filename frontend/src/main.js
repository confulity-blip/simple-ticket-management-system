import { createApp } from 'vue'
import { createPinia } from 'pinia'
import axios from 'axios'
import router from './router'
import './style.css'
import App from './App.vue'

// Configure axios to send credentials (cookies) with every request
axios.defaults.withCredentials = true
// Use environment variable for API URL, fallback to localhost for development
axios.defaults.baseURL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.mount('#app')
