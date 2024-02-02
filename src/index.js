import createHotKeyContext from './hotkey.js'

try {
  const context = await createHotKeyContext()
  await context.bind('control + option + k')
  await context.bind('cmd + k')
  await context.bind('cmd + shift + k')
  await context.bind('cmd + space')
  context.addEventListener('hotkey', console.log)
} catch (err) {
  reportError(err)
}
