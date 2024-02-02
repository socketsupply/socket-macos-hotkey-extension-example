import createHotKeyContext from './hotkey.js'

try {
  const context = await createHotKeyContext()
  const binding = await context.bind('control + option + k')
  context.addEventListener('hotkey', console.log)
} catch (err) {
  reportError(err)
}
