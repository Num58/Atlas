// REMOVED 2026-08-05 — identity red-line compliance.
//
// This file previously declared `IdentityTransitionEvent`, which carried an
// `IdentityStage` (initiate | practitioner | advanced | master). Encoding a
// system-defined identity stage for the user violates the PrimeAtlas identity
// red-line ("Atlas 不得随意替用户下身份定义"). Portrait / transition semantics are
// instead expressed via `PortraitVersionInfo.transitionNarrative` (dimension /
// axis changes only, never identity-role labels).
//
// The file is intentionally left as a comment-only stub on disk so that
// `dart analyze lib` stays clean. It is staged for deletion and is excluded
// from the committed tree.
