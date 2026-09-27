# Resume Rebuild Recommendations

## Objective

Rebuild Krzysztof Dubel's resume around a clear professional identity:

**Robotics Engineer | Physical AI | C++ | ROS | Embedded Systems**

The resume should make it immediately obvious that the candidate is a robotics engineer who works with real robots, sensors, embedded systems, controls, C++, ROS, and hardware.

"Physical AI" should support that positioning, not replace it. The candidate is **not an AI engineer**. The intended message is:

> I build the physical layer of Physical AI.

The resume should be concise, ATS-friendly, easy to maintain locally, and optimized for correct parsing by both conventional ATS systems and newer agentic resume parsers.

---

# 1. Recommended Authoring Toolchain

## Canonical source: Markdown

Use Markdown as the source of truth.

Reasons:

- already familiar
- excellent in LazyVim
- very easy to edit
- easy to diff in Git
- keeps content separate from presentation
- encourages semantic, linear document structure
- ideal for ATS-friendly documents
- can generate both PDF and DOCX
- easy to inspect with grep / text tools

The source should stay simple and readable.

Example:

```markdown
# Krzysztof Dubel

**Robotics Engineer | Physical AI | C++ | ROS | Embedded Systems**

Gdańsk, Poland · email · LinkedIn · GitHub

## Professional Summary

...

## Technical Skills

...

## Professional Experience

### Robotics Engineer — Grid Dynamics
*2024–Present · Poland*

- ...
- ...
```

---

# 2. PDF Rendering Recommendation

## Use Pandoc + Typst

Recommended pipeline:

```text
resume.md
    ↓
  Pandoc
    ↓
   Typst
    ↓
 resume.pdf
```

Do **not** start with HTML/CSS.

The goal is "fire and forget", not precise page-layout engineering.

Basic build:

```bash
pandoc resume.md \
  --to=typst \
  --output=build/Krzysztof_Dubel_Resume.pdf
```

Start with Pandoc's default Typst output.

Only introduce a custom Typst template if there is a concrete problem such as:

- margins too large
- headings too large
- excessive whitespace
- poor page breaks
- inconsistent font sizing
- resume spilling unnecessarily beyond two pages

Do not optimize typography pre-emptively.

---

# 3. Why Not HTML/CSS

HTML + CSS is capable of producing excellent PDFs, but it introduces a stack the candidate does not know well.

Typical issues include:

- print CSS
- pagination rules
- page-break behavior
- margin tuning
- font and line-height tuning
- browser/rendering differences
- CSS resets
- maintaining HTML/CSS templates

There is no compelling benefit for this resume.

Typst provides a much smaller and more controlled rendering layer.

Coming from LaTeX, Typst should also be relatively intuitive if minor customization becomes necessary.

---

# 4. Why Not Pure Typst

Pure Typst would also work, but Markdown is preferable as the canonical authoring format.

The intended separation is:

```text
Markdown = content
Typst    = rendering infrastructure
```

The candidate should spend almost all editing time in `resume.md`.

Typst should only be touched if the default rendering needs improvement.

---

# 5. Recommended Local Setup

Target environment:

- CachyOS / Arch-based Linux
- LazyVim
- Kitty
- Zathura

Suggested packages:

```bash
sudo pacman -S pandoc typst zathura zathura-pdf-mupdf poppler
```

Useful tools:

- `pandoc` — conversion
- `typst` — PDF rendering backend
- `zathura` — lightweight PDF preview
- `pdftotext` — ATS-style text extraction sanity check

Optional:

```bash
sudo pacman -S inotify-tools
```

for a simple watch workflow.

---

# 6. Minimal Project Structure

Keep the repository small.

Recommended initial structure:

```text
resume/
├── resume.md
├── Makefile
└── build/
```

Only add a Typst template if necessary:

```text
resume/
├── resume.md
├── resume.typ
├── Makefile
└── build/
```

Avoid unnecessary infrastructure such as:

```text
style.css
template.html
filters/
scripts/
complex metadata files
```

unless a real need appears.

---

# 7. Suggested Makefile

Example:

```makefile
PDF := build/Krzysztof_Dubel_Resume.pdf

pdf:
	mkdir -p build
	pandoc resume.md \
		--to=typst \
		--output=$(PDF)

check: pdf
	pdftotext $(PDF) -

watch:
	while inotifywait -e close_write resume.md; do \
		$(MAKE) pdf; \
	done
```

Possible workflow:

Terminal / Kitty split 1:

```bash
nvim resume.md
```

Terminal / Kitty split 2:

```bash
make watch
```

Open once:

```bash
zathura build/Krzysztof_Dubel_Resume.pdf
```

---

# 8. ATS Parsing Invariant

The Markdown source should define the semantic order of the document.

The goal is:

```text
Markdown semantic order
        ≈
Pandoc document order
        ≈
PDF text extraction order
        ≈
ATS parsing order
```

This is more important than visual sophistication.

After every meaningful layout change, run:

```bash
pdftotext build/Krzysztof_Dubel_Resume.pdf -
```

Do **not** rely only on visual inspection.

The extracted text should make sense top-to-bottom.

Example of good output:

```text
Control Systems Engineer — Semcon
Mar 2020 – Jun 2021
Kongsberg, Norway

Developed...
Implemented...
```

Bad output:

```text
Mar 2020 – Jun 2021
Sep 2018 – Feb 2020
...

Semcon
Luxoft
...
```

The old resume currently has this type of reading-order problem because dates are placed in a visual side column.

---

# 9. ATS Formatting Rules

Prefer:

- single-column document
- standard section headings
- normal text
- bullets
- simple inline separators
- linear reading order
- visible text links
- standard fonts
- ordinary PDF text objects

Avoid:

- sidebars
- two-column layouts
- visual date columns
- tables for layout
- text boxes
- icons containing semantic information
- skill bars
- graphical timelines
- floating elements
- embedded images containing text
- unusual heading names
- headers/footers containing important content

Employment heading format should remain linear.

Preferred:

```text
Robotics Engineer — Grid Dynamics | 2024–Present | Poland
```

Avoid visually separating dates from the employer.

---

# 10. Resume Target Length

Target:

**2 pages**

Do not force a one-page resume.

There is enough professional robotics experience to justify two pages.

The current seven-page resume is too long and dilutes the important experience.

---

# 11. Core Positioning

The resume should communicate within approximately five seconds:

> Krzysztof is an experienced robotics engineer. He writes C++. He works with ROS, sensors, controls, embedded systems, and real hardware. He works on Physical AI and industrial robotics.

The candidate should not appear primarily as:

- generic software engineer
- data engineer
- AI/ML engineer
- academic robotics graduate
- generalist with a large project catalogue

The candidate should appear as:

**senior / experienced robotics engineer with strong software depth and real hardware experience**

---

# 12. Recommended Resume Structure

Use this order:

1. Name
2. Professional headline
3. Contact information
4. Professional Summary
5. Technical Skills
6. Professional Experience
7. Education
8. Selected Certifications / Languages

Do not number sections.

Example:

```markdown
# Krzysztof Dubel

**Robotics Engineer | Physical AI | C++ | ROS | Embedded Systems**

Gdańsk, Poland · email · phone · LinkedIn · GitHub

## Professional Summary

...

## Technical Skills

...

## Professional Experience

...

## Education

...

## Certifications & Languages

...
```

---

# 13. Professional Headline

Recommended baseline:

```text
Robotics Engineer | Physical AI | C++ | ROS | Embedded Systems
```

Possible variant:

```text
Robotics Engineer | Physical AI & Industrial Robotics | C++ / ROS / Embedded Systems
```

Use **Robotics Engineer** as the primary taxonomy.

"Physical AI" should be secondary because many ATS taxonomies and human recruiters understand "Robotics Engineer" more reliably.

---

# 14. Professional Summary

Keep to approximately 2–3 lines.

It should emphasize:

- robotics
- real hardware
- C++
- ROS / ROS 2
- controls
- sensing
- embedded systems
- Physical AI

Avoid generic corporate prose.

Structure example:

```text
Robotics engineer with 8+ years of experience across autonomous systems,
industrial robotics, C++/ROS software, controls, localisation, sensing and
embedded hardware. Focused on the physical layer of Physical AI: turning
perception and planning into reliable behaviour on real robotic systems.
```

Treat this as a structural example, not finalized wording.

---

# 15. Technical Skills

Put robotics first.

Suggested grouping:

```markdown
## Technical Skills

**Robotics:** ROS / ROS 2, motion control, motion planning, localisation, SLAM,
sensor fusion, LiDAR, robot vision, industrial robotics

**Programming:** C++, Embedded C, Python, Qt

**Embedded & Hardware:** STM32, HAL, FreeRTOS, electronics, sensor integration,
KiCad

**Controls & Simulation:** MATLAB, Simulink, dynamic modelling
```

Adjust based on actual current technology stack.

If the candidate uses ROS 2 professionally, write **ROS 2** explicitly.

Likewise include concrete technologies where true, such as:

- C++17 / C++20 / C++23
- CMake
- Eigen
- MoveIt / MoveIt 2
- Gazebo
- Isaac Sim
- NVIDIA Omniverse
- Wandelbots NOVA
- Universal Robots
- Doosan
- FANUC
- PLC integration
- EtherCAT
- CAN / CANopen
- OPC UA
- Modbus
- industrial cameras
- depth cameras
- force-torque sensors
- end effectors
- calibration
- trajectory generation
- collision checking
- real-time systems
- HIL / SIL

Only include technologies actually used.

Do not keyword-stuff.

---

# 16. Content to Remove From the Existing Resume

Remove:

- `RESUME` as document title
- date of birth
- "Specialisation: Software Engineering, Robotics"
- numbered sections
- high school
- standalone Academic Activities section
- full University Courses section
- most university projects
- separate multi-page Projects catalogue
- Weather Data Analyzer
- Runaway Alarm Clock
- RAS assembly line
- old CCNA certifications
- long Interests section
- generic broad skill dumping
- legacy data-processing consent paragraph from the general resume

Remove or heavily de-emphasize:

- Apache Beam
- Google DataFlow
- generic Data Science
- generic Data Analysis
- Unity
- C#
- particle physics
- quantum mechanics
- electromagnetism

These can remain only when directly relevant to a target role.

---

# 17. Important Existing Experience to Preserve

## Semcon — Yeti

Strong robotics evidence:

- autonomous vehicle platform
- C++
- Qt
- LiDAR
- sensor fusion
- path following
- vehicle dynamics / control

This should remain visible.

## Luxoft

Strong robotics/autonomy evidence:

- C++
- ROS
- high-precision localisation
- odometry
- sensor fusion
- Kalman filtering
- computer vision
- autonomous vehicle R&D

This should remain visible.

## FANUC

Very important "real hardware" evidence:

- industrial manipulator integration
- CNC / robot cooperation
- tooling
- electronics
- pneumatics
- safety
- robot programming
- workspace integration

Do not bury this simply because it is older.

## Embedded / Hardware Work

Preserve enough evidence of:

- STM32
- Embedded C
- HAL
- FreeRTOS
- KiCad
- electronics
- soldering
- physical sensor integration
- embedded prototyping

University examples may be compressed into one concise evidence line rather than separate project descriptions.

## Education

Keep:

- Master of Engineering — Embedded Robotics
- Bachelor of Engineering — Control Engineering and Robotics / Robotics

Remove high school.

---

# 18. Professional Experience Strategy

Do not maintain both:

```text
Work Experience
```

and:

```text
Projects
```

for the same professional work.

Instead, put important project context directly underneath each employer.

Example:

```markdown
### Control Systems Engineer — Semcon
*Mar 2020 – Jun 2021 · Kongsberg, Norway*

**Yeti — Autonomous Vehicle Platform**

- Developed C++ components for autonomous vehicle functionality.
- Implemented LiDAR processing and sensor-fusion components.
- Improved path-following and vehicle-control functionality.
```

This avoids duplicated content.

---

# 19. Experience Budget

Suggested relative emphasis:

## Current Grid Dynamics role

4–5 strong bullets.

This should dominate page 1.

## Sonitor

2–3 bullets.

Focus on:

- positioning algorithms
- production software
- real-world sensing system
- validation / testing

De-emphasize Apache Beam / cloud streaming unless relevant to a job.

## Forkbeard

~2 bullets.

Focus on:

- embedded firmware
- sensors
- Bluetooth positioning
- hardware-facing development

## Semcon

~3 bullets.

Yeti should dominate.

Other projects can be compressed.

## Luxoft

2–3 bullets.

Focus on:

- C++
- ROS
- localisation
- sensor fusion
- autonomous systems
- computer vision

## Earlier Experience

Compress older Objective / FANUC / Etteplan work.

FANUC may deserve a dedicated bullet because it strongly proves industrial robotics / physical hardware experience.

---

# 20. Current Grid Dynamics Role

This is the largest missing section in the old resume.

It must clearly show what the candidate has done since 2024.

The bullets should answer:

- What robots?
- What hardware?
- What C++ code?
- What ROS / ROS 2 components?
- What perception/planning components were integrated?
- What software touched physical hardware?
- What was deployed to a real robot?
- What was tested in simulation and then on hardware?
- What industrial systems were involved?
- What technical failures or constraints had to be solved?
- What measurable improvements were achieved?

Avoid wording such as:

```text
Worked on Physical AI solutions using AI, robotics and computer vision.
```

That makes the candidate sound like a generic AI engineer.

Prefer structures such as:

```text
Integrated AI-driven perception/planning components with physical robot
systems, implementing the ROS/C++ execution and hardware-integration layer
for real-world industrial workflows.
```

or:

```text
Built and validated robot-side C++/ROS components for manipulation workflows,
bridging higher-level AI decisions with motion execution, sensors and
industrial hardware.
```

These are structural examples only. Do not invent claims.

---

# 21. Writing Style

The candidate wants to do most of the writing.

Keep bullet points compact.

Prefer:

```text
Implemented LiDAR sensor-fusion components in C++ for an autonomous vehicle platform.
```

over:

```text
Was responsible for the design, development, implementation and maintenance
of innovative LiDAR-based sensor fusion solutions...
```

Use:

- strong verbs
- technical nouns
- concrete systems
- measurable outcomes where available
- short bullets
- low adjective density

Avoid:

- bloated paragraphs
- corporate language
- filler
- "responsible for"
- "worked on"
- "participated in"
- generic "innovative solutions"

---

# 22. Repository Goal

Codex should create a minimal repository that lets the candidate:

```bash
nvim resume.md
make pdf
make check
zathura build/Krzysztof_Dubel_Resume.pdf
```

The repository should prioritize:

1. semantic correctness
2. ATS parsing
3. low maintenance
4. readability
5. typography

in that order.

---

# 23. Acceptance Criteria

The first implementation is good enough if:

- Markdown is the canonical source
- build uses Pandoc + Typst
- output PDF is searchable text
- PDF is single-column
- `pdftotext` produces correct semantic order
- no job dates become detached from employers
- no text boxes/tables are required for layout
- no ATS-critical information is in headers/footers
- layout is professional without substantial manual tuning
- document can plausibly fit in two pages once content is edited
- source remains pleasant to edit in LazyVim
- build process is one command
- layout changes do not require editing the Markdown content

Only add custom Typst infrastructure after identifying a concrete formatting problem.
