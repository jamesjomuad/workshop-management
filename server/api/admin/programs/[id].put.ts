import type { Program } from '~/types'

export default defineEventHandler(async (event): Promise<Program> => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('programs')
    .update({
      title: body.title,
      description: body.description ?? null,
      status: body.status,
      order_index: body.order_index,
      slug: body.slug,
      content: body.content,
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
