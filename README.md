## Deprecated

This project has been deprecated and is no longer maintained.

Rationale: https://github.com/hexops/mach/issues/1166

## [OR IS IT?](https://www.youtube.com/watch?v=TN25ghkfgQA)

Since the deprecation of the Mach project while the status of Mach is unknown, we shall bring this project back to live because zgpu and zgui relies on a dawn binary built originally from one of the Mach repo. This repo and the related projects will have a few crucial objectives:

- Find a painless way to update zgui and zgpu due to the rapid change of the official dawn library
- Find a way to let users choosing between dawn and [mozilla webgpu](https://developer.mozilla.org/en-US/docs/Web/API/WebGPU_API), for people who don't want to rely too much a specific technology.
- Automate the build process for the binary such that users can just go to the github release to object a specific version.

## Requirement
Due to the deprecation of Mach,the dependency of using tool from Mach is decoupled due to the outdated and hard to update codebase (stopped at ~zig 0.10.x). We have replaced the build system natively to the original dawn requirement, so you will need the following tools to make it work for the current iteration:

- zig 0.14.0
- [python 3](https://www.python.org/) and [jinja2](https://stackoverflow.com/a/18983050/20840262)
- [cmake](https://cmake.org/)
- [ninja](https://ninja-build.org/)

To build the library, all you need is to run:

```
zig build
```