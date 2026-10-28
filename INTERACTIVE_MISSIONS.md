# Interactive Missions

This checkout is an Interactive Missions marketplace. The root
[`manifest.yaml`](manifest.yaml) registers one starter mission,
**Cruise Control with LQR**, with five tasks covering modelling, the original
response, stability and controllability, LQR design, and a tracking comparison.
The mission has authored hints, observable completion checks, and reset
scripts for resuming at tasks 2-5.

The mission is marked **draft** and is visible in the catalog for review.
The remaining tutorials are available as source examples; they are not yet
listed as runnable missions.

## Requirements

- Interactive Missions toolbox (manifest minimum: 0.2.0).
- MATLAB R2026a and Control System Toolbox.
- MATLAB MCP Server and a supported agent client such as Codex.

This starter mission works entirely in MATLAB. The repository's other examples
may require Simulink and additional products.

## Preview this local checkout

With MATLAB's current folder set to this repository, inspect its catalog:

```matlab
missions = interactiveMissions.catalog(MarketplaceRoot=pwd, Audience="learner");
disp(missions(:, ["MissionName", "Title", "TaskCount", "Status"]))
```

The installed toolbox supports a root-level `manifest.yaml` with
`missions/<mission-name>/mission.yaml`. It also accepts the same layout under
a `marketplace` subfolder. Local catalog preview does not register the
checkout or prepare a learner workspace.

Check catalog discovery, every resume script, and the numerical model and
responses from MATLAB with this checkout as the current folder:

```matlab
addpath('tests')
validate_interactive_missions
```

Validation runs resets in isolated function workspaces and closes their test
figures. A complete interactive learner session is still needed before
changing the mission's status from `draft` to `published`.

## Launch through the app

1. Publish these additions to a Git repository or branch that you control.
   Set `source_url` in `manifest.yaml` to that repository's clone URL if it
   differs from upstream. The supplied URL identifies the source repository;
   uncommitted local changes are not available from that URL.
2. Register the published HTTPS or SSH Git clone URL in Interactive Missions.
   For a branch, choose that branch when registering. The MATLAB API is:

   ```matlab
   interactiveMissions.registerMarketplace( ...
       SourceUrl="https://github.com/YOUR-ACCOUNT/YOUR-REPOSITORY.git", ...
       ReferenceType="branch", ReferenceName="YOUR-BRANCH");
   ```

3. Open the Interactive Missions app, choose **Cruise Control with LQR**,
   and select **Start Mission** or **Practice** with your preferred client.
4. Open the generated learner workspace in the selected client. For Codex,
   invoke `$mission-tutoring` and follow the tutor one task at a time.

Registration fetches a remote Git repository; it does not accept a local
folder. The toolbox copies tutor skills and client adapters into the prepared
workspace. This marketplace only declares their IDs.

## Source and packaging

The mission uses the vehicle parameters and LQR weights in
[`LQR Control/cruise_control_lqr.m`](LQR%20Control/cruise_control_lqr.m) and the
modelling topic in
[`System Models/cruise_control_ss.m`](System%20Models/cruise_control_ss.m),
from upstream commit `877271c`. The LQR source credits the University of
Michigan Control Tutorials for MATLAB and Simulink for the cruise-control model.

The mission is self-contained: learners create the model themselves, and its
reset scripts reconstruct preceding task state. It does not run the original
scripts or depend on files outside the prepared mission bundle. The original
scripts remain reference material; for example, `cruise_control_ss.m` refers
to an undefined `cruise_ss`, and some other examples are unfinished.

To add another mission, create `missions/<slug>/mission.yaml`, declare its
requirements, tasks, hints, and checks, and add its path to the manifest.
The toolbox copies only the mission YAML, a declared setup script, a declared
thumbnail, and `task_reset_<slug>/`. Arbitrary `.m`, `.slx`, and `.mat` files
elsewhere in the repository will not be copied into learner workspaces.
