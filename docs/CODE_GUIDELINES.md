# CODE_GUIDELINES.md

> Empirically derived from actual code in `app/`. These are the conventions this project **actually** follows, not aspirational ones.

---

## 1. Vue Component Conventions

### Script Setup

Every component uses `<script setup lang="ts">`. No Options API anywhere.

### definePageMeta — REQUIRED on every page

```typescript
// Public page
definePageMeta({ layout: 'default' })

// Auth-protected admin page
definePageMeta({ layout: 'dashboard', middleware: 'auth' })
```

Call it as a top-level statement, not inside a function.

### Component Names

Multi-word PascalCase: `SidebarNav.vue`, `AppHeader.vue`, `VenueCard.vue`, `EventTypeGrid.vue`.

### Props

Use the generics syntax, not the object syntax:

```typescript
// ✅ Correct
defineProps<{ venue: Venue; title?: string }>()

// ❌ Avoid
defineProps({ venue: { type: Object, required: true } })
```

### Emits

Use the typed syntax:

```typescript
defineEmits<{ 'toggle-drawer': []; select: [id: string] }>()
```

### Styles

- Use `<style scoped>` for component-specific styles.
- Use unscoped `<style>` only in layouts for global page transitions.
- Use `rgb(var(--v-theme-*))` for dynamic theme colors (dark mode compatible).
- Use `.dark .selector { ... }` for dark-mode overrides.

---

## 2. Template Structure

### Vuetify Components (most-used)

| Component | Standard Props |
|-----------|---------------|
| `v-text-field`, `v-textarea` | `variant="outlined" density="comfortable" hide-details` |
| `v-select`, `v-autocomplete` | `item-title="..." item-value="id" :items="..." variant="outlined"` |
| `v-btn` | `color="primary" variant="outlined|text|flat" size="small|large"` |
| `v-chip` | `size="x-small|small" variant="tonal"` |
| `v-card` | `rounded="lg" variant="outlined|elevation"` |
| `v-data-table` | `density="compact|comfortable" item-value="id"` |
| `v-form` | `ref="formRef" @submit.prevent="handleSave"` |

### Loading/Empty/Error States

Three-state rendering pattern:

```vue
<div v-if="data">
  <!-- content -->
</div>
<div v-else-if="loading" class="text-center py-10">
  <v-progress-circular indeterminate color="primary" />
</div>
<div v-else class="text-center py-10">
  <p class="text-grey">Not found.</p>
</div>
```

Empty list state:

```vue
<div v-if="items.length === 0 && !pending" class="py-12 text-center text-medium-emphasis">
  <v-icon size="48" class="mb-2">mdi-calendar-blank</v-icon>
  <div class="text-body-1 font-weight-medium">No items found</div>
  <div class="text-caption mt-1">Try adjusting the filter</div>
</div>
```

### Snackbar Pattern

```typescript
const snackbar = ref({ show: false, text: '', color: 'success' })
```

```vue
<v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">{{ snackbar.text }}</v-snackbar>
```

---

## 3. Form Conventions

### Form State

Use `reactive()` for multi-field forms, `ref()` for standalone values:

```typescript
const form = reactive({
  name: '',
  email: '',
  capacity: 50,
  status: 'available' as 'available' | 'booked',
})

const formRef = ref<VForm>()
```

### Validation Rules

Arrow-function arrays:

```typescript
const required = [(v: any) => !!v || 'Required']
const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+/.test(v) || 'Enter a valid email',
]
```

### Submit Handler

```typescript
async function handleSave() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return

  loading.value = true
  error.value = ''
  try {
    // API call
    // Show success
  } catch (err: any) {
    // Show error
  } finally {
    loading.value = false
  }
}
```

---

## 4. Composables

### Naming

Named export with `use` prefix. No default exports.

```typescript
export function useAuth() { ... }
export function useAdminWorkshops() { ... }
```

### Structure

Return an object with reactive state + action functions:

```typescript
export function useX() {
  const { data, pending, error, refresh } = useFetch<Type>(url)

  async function mutate(payload) {
    const { error } = await useFetch(url, { method: 'POST', body: payload })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  return { data, pending, error, refresh, mutate }
}
```

### API Call Patterns

**GET** (via composable or `useFetch` directly):
```typescript
const { data, pending, error, refresh } = useFetch<Type>(url)
```

**Mutation** (POST/PUT/DELETE):
```typescript
const { error } = await useFetch(url, { method: 'POST', body: payload })
if (error.value) throw new Error(error.value.message)
await refresh()
```

### Error Handling

- Functions throw errors. Composables do NOT catch — callers handle.
- Direct Supabase calls: `if (error) throw error`
- `useFetch` calls: `if (error.value) throw new Error(error.value.message)`

### Type Imports

```typescript
import type { Workshop, ConferenceRoom } from '~/types'
```

---

## 5. Middleware

```typescript
export default defineNuxtRouteMiddleware(async () => {
  const user = useSupabaseUser()
  if (!user.value) return navigateTo('/login')
  // optional role check
})
```

---

## 6. Data Tables

```typescript
const headers = [
  { title: 'Name', key: 'name', sortable: true },
  { title: 'Actions', key: 'actions', sortable: false, width: 96 },
]
```

```vue
<v-data-table
  :headers="headers"
  :items="items ?? []"
  :loading="pending"
  :search="search"
  item-value="id"
  density="comfortable"
  sortable
/>
```

---

## 7. Imports

- Do NOT import Nuxt/Vue APIs — they are auto-imported (`ref`, `computed`, `reactive`, `useFetch`, `useRouter`, `navigateTo`, `definePageMeta`, `onMounted`, `watch`, etc.)
- Do NOT import composables — they are auto-imported (`useAuth`, `useAdminWorkshops`, etc.)
- Do NOT import Vuetify components — they are auto-imported
- Import types explicitly: `import type { X } from '~/types'`
- Type alias: `~/` → `app/`

---

## 8. Navigation

- In pages: use `await navigateTo('/path')`
- In composables: `router.push('/path')` (from `useRouter()`)
- In middleware: `return navigateTo('/path')`

---

## 9. CSS Conventions

### Custom classes (reused across files)

- `.font-family-mono` — monospace font stack
- `.cursor-pointer` — pointer cursor
- `.opacity-60` — reduced opacity (completed/cancelled items)
- `.border-dashed` — dashed border style
- `.bg-surface-alt` — alternate background tint

### Theme Colors

Use Vuetify CSS variables for theme awareness:

```css
color: rgb(var(--v-theme-primary));
background: rgb(var(--v-theme-navy));
border-color: rgb(var(--v-theme-primary));
```

### Dark Mode

```css
.dark .my-class {
  background: rgba(18, 18, 18, 0.85);
}
```

---

## 10. Monorepo Style Note

- All package scripts: `npm run dev`, `npm run build`, `npm run generate`, `npm run preview`
- No lint, typecheck, or test scripts exist
- `postinstall` runs `nuxt prepare`

---

## 11. Known Inconsistencies (Do Not Replicate)

- **`confirm.vue`** uses `ref()` per field instead of `reactive({})` — use `reactive()` for forms
- **`as any`** cast on workshop status types — use proper typing instead

---

## 12. Vuetify Theme

```typescript
// nuxt.config.ts
primary: '#F59E0B'      // amber
secondary: '#0D9488'    // teal
navy: '#1B2A4A'         // dark navy
charcoal: '#2D3436'     // charcoal
```

Dark mode equivalents: `#FBBF24` (primary), `#2DD4BF` (secondary), `#0F172A` (navy), `#1E1E1E` (charcoal).
