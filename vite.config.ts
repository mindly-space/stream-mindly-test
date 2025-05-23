import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import svgr from 'vite-plugin-svgr';
import checker from 'vite-plugin-checker';
import progress from 'vite-plugin-progress';

export default defineConfig({
  plugins: [
    react(),
    svgr(),
    checker({
      typescript: true,
      eslint: {
        lintCommand: 'eslint "./src/**/*.{ts,tsx}"',
      },
    }),
    progress(),
  ],
  resolve: {
    alias: {
      src: '/src',
    },
  },
  build: {
    outDir: 'build',
  },
  server: {
    hmr: { host: 'localhost' },
    strictPort: true,
    port: 3000,
  },
});
