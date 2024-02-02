#include <Cocoa/Cocoa.h>
#include <socket/extension.h>
#include <Carbon/Carbon.h>

#include <map>
#include <mutex>
#include <ranges>
#include <string>
#include <vector>

// global available to extension
static UInt32 nextBindingID = 1;
static std::recursive_mutex mutex;

std::string& trim (std::string& input) {
	const auto filter = [](unsigned char c){ return !std::isspace(c); };

	input.erase(
		std::ranges::find_if(input | std::views::reverse, filter).base(),
		input.end()
	);

	input.erase(
		input.begin(),
		std::ranges::find_if(input, filter)
	);

	return input;
}

class HotKeyCodeMap {
  public:
    using Code = unsigned int;
    using Map = std::map<std::string, Code>;

    Map keys;
    Map modifiers;

    HotKeyCodeMap () {
      keys.insert_or_assign("a", kVK_ANSI_A);
      keys.insert_or_assign("b", kVK_ANSI_B);
      keys.insert_or_assign("c", kVK_ANSI_C);
      keys.insert_or_assign("d", kVK_ANSI_D);
      keys.insert_or_assign("e", kVK_ANSI_E);
      keys.insert_or_assign("f", kVK_ANSI_F);
      keys.insert_or_assign("g", kVK_ANSI_G);
      keys.insert_or_assign("h", kVK_ANSI_H);
      keys.insert_or_assign("i", kVK_ANSI_I);
      keys.insert_or_assign("j", kVK_ANSI_J);
      keys.insert_or_assign("k", kVK_ANSI_K);
      keys.insert_or_assign("l", kVK_ANSI_L);
      keys.insert_or_assign("m", kVK_ANSI_M);
      keys.insert_or_assign("n", kVK_ANSI_N);
      keys.insert_or_assign("o", kVK_ANSI_O);
      keys.insert_or_assign("p", kVK_ANSI_P);
      keys.insert_or_assign("q", kVK_ANSI_Q);
      keys.insert_or_assign("r", kVK_ANSI_R);
      keys.insert_or_assign("s", kVK_ANSI_S);
      keys.insert_or_assign("t", kVK_ANSI_T);
      keys.insert_or_assign("u", kVK_ANSI_U);
      keys.insert_or_assign("v", kVK_ANSI_V);
      keys.insert_or_assign("w", kVK_ANSI_W);
      keys.insert_or_assign("x", kVK_ANSI_X);
      keys.insert_or_assign("y", kVK_ANSI_Y);
      keys.insert_or_assign("z", kVK_ANSI_Z);
      keys.insert_or_assign("0", kVK_ANSI_0);
      keys.insert_or_assign("1", kVK_ANSI_1);
      keys.insert_or_assign("2", kVK_ANSI_2);
      keys.insert_or_assign("3", kVK_ANSI_3);
      keys.insert_or_assign("4", kVK_ANSI_4);
      keys.insert_or_assign("5", kVK_ANSI_5);
      keys.insert_or_assign("6", kVK_ANSI_6);
      keys.insert_or_assign("7", kVK_ANSI_7);
      keys.insert_or_assign("8", kVK_ANSI_8);
      keys.insert_or_assign("9", kVK_ANSI_9);
      keys.insert_or_assign("=", kVK_ANSI_Equal);
      keys.insert_or_assign("-", kVK_ANSI_Minus);
      keys.insert_or_assign("]", kVK_ANSI_RightBracket);
      keys.insert_or_assign("[", kVK_ANSI_LeftBracket);
      keys.insert_or_assign("'", kVK_ANSI_Quote);
      keys.insert_or_assign(";", kVK_ANSI_Semicolon);
      keys.insert_or_assign("\\", kVK_ANSI_Backslash);
      keys.insert_or_assign(",", kVK_ANSI_Comma);
      keys.insert_or_assign("/", kVK_ANSI_Slash);
      keys.insert_or_assign(".", kVK_ANSI_Period);
      keys.insert_or_assign("`", kVK_ANSI_Grave);

      keys.insert_or_assign("return", kVK_Return);
      keys.insert_or_assign("enter", kVK_Return);
      keys.insert_or_assign("tab", kVK_Tab);
      keys.insert_or_assign("space", kVK_Space);
      keys.insert_or_assign("delete", kVK_Delete);
      keys.insert_or_assign("escape", kVK_Escape);
      keys.insert_or_assign("shift", kVK_Shift);
      keys.insert_or_assign("caps lock", kVK_CapsLock);
      keys.insert_or_assign("right shift", kVK_RightShift);
      keys.insert_or_assign("right option", kVK_RightOption);
      keys.insert_or_assign("right opt", kVK_RightOption);
      keys.insert_or_assign("right alt", kVK_RightOption);
      keys.insert_or_assign("right control", kVK_RightControl);
      keys.insert_or_assign("right ctrl", kVK_RightControl);
      keys.insert_or_assign("fn", kVK_Function);
      keys.insert_or_assign("volume up", kVK_VolumeUp);
      keys.insert_or_assign("volume down", kVK_VolumeDown);
      keys.insert_or_assign("mute", kVK_Mute);
      keys.insert_or_assign("f1", kVK_F1);
      keys.insert_or_assign("f2", kVK_F2);
      keys.insert_or_assign("f3", kVK_F4);
      keys.insert_or_assign("f4", kVK_F3);
      keys.insert_or_assign("f5", kVK_F5);
      keys.insert_or_assign("f6", kVK_F6);
      keys.insert_or_assign("f7", kVK_F7);
      keys.insert_or_assign("f8", kVK_F8);
      keys.insert_or_assign("f9", kVK_F9);
      keys.insert_or_assign("f10", kVK_F10);
      keys.insert_or_assign("f11", kVK_F11);
      keys.insert_or_assign("f12", kVK_F12);
      keys.insert_or_assign("f13", kVK_F13);
      keys.insert_or_assign("f14", kVK_F14);
      keys.insert_or_assign("f15", kVK_F15);
      keys.insert_or_assign("f16", kVK_F16);
      keys.insert_or_assign("f17", kVK_F17);
      keys.insert_or_assign("f18", kVK_F18);
      keys.insert_or_assign("f18", kVK_F19);
      keys.insert_or_assign("f20", kVK_F20);
      keys.insert_or_assign("elp", kVK_Help);
      keys.insert_or_assign("home", kVK_Home);
      keys.insert_or_assign("end", kVK_End);
      keys.insert_or_assign("page up", kVK_PageUp);
      keys.insert_or_assign("page down", kVK_PageDown);
      keys.insert_or_assign("up", kVK_UpArrow);
      keys.insert_or_assign("down", kVK_DownArrow);
      keys.insert_or_assign("left", kVK_LeftArrow);
      keys.insert_or_assign("right", kVK_RightArrow);

      modifiers.insert_or_assign("command", cmdKey);
      modifiers.insert_or_assign("super", cmdKey);
      modifiers.insert_or_assign("cmd", cmdKey);
      modifiers.insert_or_assign("apple", cmdKey);

      modifiers.insert_or_assign("option", optionKey);
      modifiers.insert_or_assign("opt", optionKey);
      modifiers.insert_or_assign("alt", optionKey);

      modifiers.insert_or_assign("control", controlKey);
      modifiers.insert_or_assign("ctrl", controlKey);
    }

    const Code get (std::string key) const {
      // normalize key to lower case
      std::transform(
        key.begin(),
        key.end(),
        key.begin(),
        [](auto ch) { return std::tolower(ch); }
      );

			if (keys.contains(key)) {
        return keys.at(key);
      }

			if (modifiers.contains(key)) {
        return modifiers.at(key);
      }

      return -1;
    }

    const bool isModifier (std::string key) const {
      // normalize key to lower case
      std::transform(
        key.begin(),
        key.end(),
        key.begin(),
        [](auto ch) { return std::tolower(ch); }
      );

      return modifiers.contains(key);
    }

    const bool isKey (std::string key) const {
      // normalize key to lower case
      std::transform(
        key.begin(),
        key.end(),
        key.begin(),
        [](auto ch) { return std::tolower(ch); }
      );

      return keys.contains(key);
    }
};

class HotKeyBinding {
  public:
    using Token = std::string;
    using Sequence = std::vector<Token>;
    using Expression = std::string;

    static Sequence parseExpression (Expression input) {
      static const auto delimiter = "+";
      Sequence sequence;
      Token token;
      // cursor state
      size_t start = 0;
      size_t end = -1;

      // convert input expression to lower case
      std::transform(
        input.begin(),
        input.end(),
        input.begin(),
        [](auto ch) { return std::tolower(ch); }
      );

      while ((end = input.find(delimiter, start)) != std::string::npos) {
        token = input.substr(start, end - start);
        sequence.push_back(trim(token));
        // move cursor forward
        start = end + 1; // end + delimiter length
      }

      // append last expression token to sequence
      token = input.substr(start);
      sequence.push_back(trim(token));
      return sequence;
    }

    HotKeyCodeMap codeMap;
    HotKeyCodeMap::Code modifiers = 0;
    HotKeyCodeMap::Code keys = 0;
    Expression expression;
    Sequence sequence;
    UInt32 id = 0;

    // Carbon API
    EventHotKeyRef eventHotKeyRef;

    HotKeyBinding (UInt32 id, Expression input) : id(id) {
      expression = input;
      sequence = parseExpression(input);

      for (const auto& token : sequence) {
        const auto code = codeMap.get(token);
        if (codeMap.isModifier(token)) {
          modifiers += code;
        } else if (codeMap.isKey(token)) {
          keys += code;
        }
      }
    }
};

class HotKeyContext {
  public:
    using Bindings = std::map<UInt32, HotKeyBinding>;

    static OSStatus eventHandlerCallback (
      EventHandlerCallRef eventHandlerCallRef,
      EventRef eventRef,
      void* userData
    ) {
      // The hot key event identifier that has an unique internal id that maps
      // to a specific hot key binding in a context
      EventHotKeyID eventHotKeyID;

      // bail early if somehow user data is `nullptr`,
      // meaning we are unable to deteremine a `HotKeyContext`
      if (userData == nullptr) {
        return noErr;
      }

      auto hotKeyContext = reinterpret_cast<HotKeyContext*>(userData);
      auto context = hotKeyContext->context;

      // if the context was removed somehow, bail early
      if (context == nullptr) {
        return noErr;
      }

      GetEventParameter(
        eventRef,
        kEventParamDirectObject,
        typeEventHotKeyID,
        NULL,
        sizeof(eventHotKeyID),
        NULL,
        &eventHotKeyID
      );

      if (hotKeyContext->bindings.contains(eventHotKeyID.id)) {
        // a temporary context for allocating JSON that will be released
        // after the 'hotkey' event is dispatched
        auto eventContext = sapi_context_create(context, true);
        auto& binding = hotKeyContext->bindings.at(eventHotKeyID.id);

        auto expression = sapi_json_string_create(eventContext, binding.expression.c_str());
        auto sequence = sapi_json_array_create(eventContext);
        auto data = sapi_json_object_create(eventContext);
        auto id = sapi_json_number_create(eventContext, binding.id);

        for (const auto& token : binding.sequence) {
          const auto value = sapi_json_string_create(eventContext, token.c_str());
          sapi_json_array_push(sequence, value);
        }

        sapi_json_object_set(data, "expression", expression);
        sapi_json_object_set(data, "sequence", sequence);
        sapi_json_object_set(data, "id", id);

        // dispatch 'hotkey' event to webview
        sapi_ipc_emit(context, "hotkey", sapi_json_stringify(data));

        // release `eventContext` in aasync context
        sapi_context_dispatch(context, eventContext, [](auto context, const auto data) {
          auto eventContext = const_cast<sapi_context_t*>(
            reinterpret_cast<const sapi_context_t*>(data)
          );

          if (eventContext != nullptr) {
            sapi_context_release(eventContext);
          }
        });
      }

      return noErr;
    }

    // Carbon API
    EventTargetRef eventTarget;

    // SAPI
    sapi_context_t* context = nullptr;

    // state
    Bindings bindings;

    HotKeyContext (sapi_context_t* extensionContext) {
      // Carbon API event type spec
      static const EventTypeSpec eventTypeSpec = {
        .eventClass = kEventClassKeyboard,
        .eventKind = kEventHotKeyPressed
      };

      eventTarget = GetApplicationEventTarget();
      context = sapi_context_create(extensionContext, true);
      sapi_context_set_data(context, this);
      InstallApplicationEventHandler(
        &eventHandlerCallback,
        1,
        &eventTypeSpec,
        this,
        nullptr
      );
    }

    ~HotKeyContext () {
      // unregister bindings, likely when the extension is unloaded
      for (const auto& entry : bindings) {
        UnregisterEventHotKey(entry.second.eventHotKeyRef);
      }

      sapi_context_release(context);
    }

    const HotKeyBinding bind (HotKeyBinding::Expression expression) {
      // this is a global extension action, lock state for life time of function
      std::lock_guard<std::recursive_mutex> lock(mutex);
      auto binding = HotKeyBinding(nextBindingID++, expression);

      EventHotKeyID eventHotKeyID;
      eventHotKeyID.id = binding.id;
      eventHotKeyID.signature = binding.id;

      RegisterEventHotKey(
        binding.keys,
        binding.modifiers,
        eventHotKeyID,
        eventTarget,
        0,
        &binding.eventHotKeyRef
      );

      bindings.insert_or_assign(binding.id, binding);

      return binding;
    }
};

static void onHotKeyRegister (
  sapi_context_t* context,
  sapi_ipc_message_t* message,
  const sapi_ipc_router_t* router
) {
  auto hotKeyContext = const_cast<HotKeyContext*>(
    reinterpret_cast<const HotKeyContext*>(sapi_context_get_data(context))
  );

  auto result = sapi_ipc_result_create(context, message);
  auto expression = sapi_ipc_message_get(message, "expression");

  if (hotKeyContext == nullptr) {
    sapi_ipc_reply_with_error(result, "Unable to determine a HotKeyContext");
    return;
  }

  if (expression == nullptr) {
    sapi_ipc_reply_with_error(result, "Missing 'expression' in arguments");
    return;
  }

  auto binding = hotKeyContext->bind(expression);

  auto sequence = sapi_json_array_create(context);
  auto data = sapi_json_object_create(context);
  auto id = sapi_json_number_create(context, binding.id);

  for (const auto& token : binding.sequence) {
    const auto value = sapi_json_string_create(context, token.c_str());
    sapi_json_array_push(sequence, value);
  }

  sapi_json_object_set(data, "expression", expression);
  sapi_json_object_set(data, "sequence", sequence);
  sapi_json_object_set(data, "id", id);

  sapi_ipc_result_set_json_data(result, sapi_json_any(data));
  sapi_ipc_reply(result);
}

static void onHotKeyMap (
  sapi_context_t* context,
  sapi_ipc_message_t* message,
  const sapi_ipc_router_t* router
) {
  static const HotKeyCodeMap map;

  auto result = sapi_ipc_result_create(context, message);
  auto type = sapi_ipc_message_get(message, "type");
  auto data = sapi_json_object_create(context);

  if (type == nullptr || std::string(type) == "keys") {
    auto keys = sapi_json_object_create(context);
    for (const auto& entry : map.keys) {
      const auto value = sapi_json_number_create(context, entry.second);
      sapi_json_object_set(keys, entry.first.c_str(), value);
    }

    sapi_json_object_set(data, "keys", keys);
  }

  if (type == nullptr || std::string(type) == "modifiers") {
    auto modifiers = sapi_json_object_create(context);
    for (const auto& entry : map.modifiers) {
      const auto value = sapi_json_number_create(context, entry.second);
      sapi_json_object_set(modifiers, entry.first.c_str(), value);
    }

    sapi_json_object_set(data, "modifiers", modifiers);
  }

  if (
    type != nullptr &&
    std::string(type) != "keys" &&
    std::string(type) != "modifiers"
  ) {
    sapi_ipc_reply_with_error(
      result,
      "Invalid 'type' given in arguments. Expecting 'keys' or 'modifiers'"
    );
    return;
  }

  sapi_ipc_result_set_json_data(result, sapi_json_any(data));
  sapi_ipc_reply(result);
}

static bool initialize (sapi_context_t* context, const void* data) {
  auto hotKeyContext = new HotKeyContext(context);

  // store in extension context to release in deinitialize
  sapi_context_set_data(context, hotKeyContext);
  sapi_ipc_router_map(context, "hotkey.register", onHotKeyRegister, hotKeyContext);
  sapi_ipc_router_map(context, "hotkey.map", onHotKeyMap, hotKeyContext);
  return true;
}

static bool deinitialize (sapi_context_t* context, const void* data) {
  auto hotKeyContext = const_cast<HotKeyContext*>(
    reinterpret_cast<const HotKeyContext*>(sapi_context_get_data(context))
  );

  if (hotKeyContext != nullptr) {
    delete hotKeyContext;
  }

  return true;
}


SOCKET_RUNTIME_REGISTER_EXTENSION(
  "hotkey",
  initialize,
  deinitialize
);
