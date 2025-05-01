# TODO List for Priorities 1 and 2

## Priority 1: Create abstraction layers between major modules

### Task 1.1: Design Properties Module Interface

- [x] Create an `IPropertyProvider` interface in a new file `src/properties/interfaces.jl`
- [x] Define methods for property checking that don't expose internal implementation details
- [x] Update the existing property registry to implement this interface
- [x] Add comprehensive documentation for each interface method

### Task 1.2: Create Templates-Properties Adapter

- [x] Create a new file `src/templates/adapters/property_adapter.jl`
- [x] Implement an adapter that converts between Templates' property requirements and Properties' interface
- [x] Refactor `meets_function_requirements()` to use this adapter
- [x] Add unit tests to verify adapter functionality

### Task 1.3: Design Oracles Module Interface

- [x] Create an `IOracleProvider` interface in a new file `src/oracles/interfaces.jl`
- [x] Define methods for oracle retrieval and composition
- [x] Update the existing oracle registry to implement this interface
- [x] Add comprehensive documentation for each interface method

### Task 1.4: Create Templates-Oracles Adapter

- [x] Create a new file `src/templates/adapters/oracle_adapter.jl`
- [x] Implement an adapter that converts between Templates' oracle requirements and Oracles' interface
- [x] Refactor relevant template matching code to use this adapter
- [x] Add unit tests to verify adapter functionality

### Task 1.5: Design Language-Properties Interface

- [ ] Create an interface for accessing expression structure in `src/language/interfaces.jl`
- [ ] Define methods that properties can use without depending on specific implementation details
- [ ] Update relevant Language module components to implement this interface
- [ ] Refactor Properties module to use these interfaces instead of direct access

### Task 1.6: Create Factory for Expression Types

- [ ] Create an `ExpressionFactory` in `src/language/factory.jl`
- [ ] Implement factory methods for all expression types
- [ ] Refactor existing code to use factory methods instead of direct construction
- [ ] Add validation and error handling within the factory

### Task 1.7: Update Module Documentation

- [ ] Update module-level documentation to describe new interfaces
- [ ] Create interface diagrams showing the relationships between modules
- [ ] Document the adapter pattern implementations
- [ ] Update user guide with examples using the new interfaces

## Priority 2: Replace global registries with context objects

### Task 2.1: Design Context Objects

- [ ] Create a `PropertiesContext` class in `src/properties/context.jl`
- [ ] Design methods to register and retrieve properties without global state
- [ ] Add support for scoped property registration and querying
- [ ] Implement serialization/deserialization for context persistence

### Task 2.2: Update Properties Registry

- [ ] Refactor the properties registry to use context objects
- [ ] Create methods to convert between the old and new approaches for backward compatibility
- [ ] Update all property registry calls throughout the codebase
- [ ] Add tests for the new context-based property registry

### Task 2.3: Create Oracles Context

- [ ] Create an `OraclesContext` class in `src/oracles/context.jl`
- [ ] Design methods for registering and retrieving oracles with context
- [ ] Add support for oracle composition within a specific context
- [ ] Implement context inheritance for hierarchical oracle resolution

### Task 2.4: Update Oracles Registry

- [ ] Refactor the oracles registry to use context objects
- [ ] Create methods to convert between old and new approaches for backward compatibility
- [ ] Update all oracle registry calls throughout the codebase
- [ ] Add tests for the new context-based oracle registry

### Task 2.5: Create Templates Context

- [ ] Create a `TemplatesContext` class in `src/templates/context.jl`
- [ ] Design methods for registering and retrieving templates with context
- [ ] Add support for template versioning within contexts
- [ ] Implement context-based template matching

### Task 2.6: Update Templates Registry

- [ ] Refactor the templates registry to use context objects
- [ ] Create methods to convert between old and new approaches for backward compatibility
- [ ] Update all template registry calls throughout the codebase
- [ ] Add tests for the new context-based template registry

### Task 2.7: Create Dependency Injection System

- [ ] Design a simple dependency injection container in `src/core/di.jl`
- [ ] Implement methods to register and resolve dependencies
- [ ] Add support for singleton and transient context registrations
- [ ] Create helper methods for common dependency resolution patterns

### Task 2.8: Implement Entry Points with Context

- [ ] Update the main module entry points to use contexts
- [ ] Create convenience methods that use default contexts
- [ ] Implement a global application context for backward compatibility
- [ ] Add documentation on context usage with examples

### Task 2.9: Update Tests for Context Objects

- [ ] Refactor tests to use isolated contexts
- [ ] Create helper methods for test context setup and teardown
- [ ] Add tests specifically for context behavior
- [ ] Verify that all existing functionality works with contexts
