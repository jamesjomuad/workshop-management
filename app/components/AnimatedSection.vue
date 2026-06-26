<template>
  <div ref="el" :class="['animated-section', { visible }]">
    <slot />
  </div>
</template>

<script setup lang="ts">
const el = ref<HTMLElement>()
const visible = ref(false)

onMounted(() => {
  const observer = new IntersectionObserver(
    ([entry]) => {
      if (entry.isIntersecting) {
        visible.value = true
        observer.unobserve(el.value!)
      }
    },
    { threshold: 0.1 }
  )
  if (el.value) observer.observe(el.value)
  onUnmounted(() => observer.disconnect())
})
</script>

<style scoped>
.animated-section {
  opacity: 0;
  transform: translateY(30px);
  transition: opacity 0.6s ease, transform 0.6s ease;
}

.animated-section.visible {
  opacity: 1;
  transform: translateY(0);
}
</style>
