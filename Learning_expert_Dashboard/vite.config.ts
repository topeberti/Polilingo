import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  },
  optimizeDeps: {
    include: [
      'react',
      'react-dom',
      'react-admin',
      'ra-data-simple-rest',
      '@mui/material',
      '@mui/icons-material',
      '@emotion/react',
      '@emotion/styled',
      '@supabase/supabase-js'
    ],
  },
})
