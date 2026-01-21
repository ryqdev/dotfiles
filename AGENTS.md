Composition over inheritance; try to avoid using inheritance whenever possible

# Rust
* Use anyhow
* type Error = Box<dyn std::error::Error + Send + Sync>;
