package io.flutter.plugin.common;

/**
 * Minimal stub for Flutter's legacy PluginRegistry. This is needed
 * for compatibility with old plugins that still declare a
 * `registerWith(PluginRegistry.Registrar registrar)` method when
 * using the new embedding. The stub satisfies compilation but is
 * never used at runtime.
 */
public interface PluginRegistry {
    /** Empty registrar interface for legacy plugins. */
    interface Registrar {
    }
}
