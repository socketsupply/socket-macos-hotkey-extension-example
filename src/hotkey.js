/* global Messagevent */
import extension from 'socket:extension'

export class HotKeyEvent extends MessageEvent {
  #id = null
  constructor (data) {
    super('hotkey', { data })
    this.#id = data.id
  }

  get id () {
    return this.id
  }
}

export class HotKeyContext extends EventTarget {
  keys = new Map()
  bindings = new Map()
  modifiers = new Map()

  #extension = null

  constructor () {
    super()
    this.onHotKey = this.onHotKey.bind(this)
    globalThis.addEventListener('hotkey', this.onHotKey)
  }

  get extension () {
    return this.#extension
  }

  onHotKey (event) {
    const { detail } = event
    if (detail?.id) {
      const { id } = detail
      if (this.bindings.has(id)) {
        this.dispatchEvent(new HotKeyEvent(detail))
      }
    }
  }

  async init () {
    this.#extension = await extension.load('hotkey')
    const map = await this.map()

    for (const key in map.keys) {
      this.keys.set(key, map.keys[key])
    }

    for (const key in map.modifiers) {
      this.modifiers.set(key, map.modifiers[key])
    }
  }

  async destroy () {
    globalThis
  }

  async map () {
    const result = await this.#extension.binding.map()

    if (result.err) {
      throw result.err
    }

    return result.data
  }

  async bind (expression) {
    const result = await this.#extension.binding.register({ expression })

    if (result.err) {
      throw result.err
    }

    const binding = result.data
    this.bindings.set(binding.id, binding)
    return binding
  }
}

export default async function createHotKeyContext () {
  const context = new HotKeyContext()
  await context.init()
  return context
}
