# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Run STARS Submission Checks](https://github.com/STARS-Design-Track-2025/nebula-iii/actions/workflows/stars_submission_checks.yml/badge.svg)](https://github.com/STARS-Design-Track-2025/nebula-iii/actions/workflows/stars_submission_checks.yml) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

| :exclamation: Important Note            |
|-----------------------------------------|

## Please fill in your project documentation in this README.md file 

Refer to [README](docs/source/index.rst#section-quickstart) for a quickstart of how to use caravel_user_project

Refer to [README](docs/source/index.rst) for this sample project documentation. 

Refer to the following [readthedocs](https://caravel-sim-infrastructure.readthedocs.io/en/latest/index.html) for how to add cocotb tests to your project. 

## Getting Started (For Mentors)

This repository should contain all of the instructions, base files, and scripts for an `openlane2` Caravel project.  
Have the students follow the [Getting Started (For Students)](https://github.com/STARS-Design-Track-2025/nebula-iii?tab=readme-ov-file#getting-started-for-students) section below and approve pull requests ONLY when the 
team is completely done AND has passed all of the GitHub actions checks. The major requirements are that teams have a successful 
testbench that PROGRAMMATICALLY tests their designs and that they pass some of the formatting checks. If you (PMs) 
discover issues during integration, please feel free to update / add to these formatting checks. At a bare minimum, 
their testbench must fail if their design is not present in the top-level NEBULA design (this is a funny requirement, but we 
have had multiple teams' test benches pass before with their entire design commented out ☺ ).

## Getting Started (For Students)

1. [**CAUTION:** Only 1 person in your team should complete this step!] Create a fork of this repository. Call your fork `nebula-iii-team-##`, where ## is your 2-digit team number in decimal, and make sure it is owned by the **STARS-Design-Track-2025** organization. If you don't know how to create a fork or what your team number is, ask your peer mentor.

2. Within your Purdue ECN career account, open a terminal and clone your fork repository. If you have any issues doing this, you may need to create and set up SSH keys. If needed, ask your peer mentor for help.

3. To create the initial files for your team, run `make init_team_##`. The created files are contained within the following folders:
* `docs/team_##` - Will contain documentation about your project, functionality description, and RTL block diagrams.
* `openlane/team_##` - Will contain the config file that you must fill before generating the physical layout of your design with OpenLane.
* `verilog/dv/team_##` - Will contain the Caravel top-level testbench (with your design included), your design's top-level testbench, and any sub-module testbench.
* `verilog/rtl/team_projects/team_##` - Will contain all the RTL SystemVerilog/Verilog code files, including your team's top-level module, sub-modules, and the team's wrapper files.<br>
**NOTE:** The files for a sample project, `team_00`, are available. Do NOT modify them, but feel free to review them if you want to understand what it does. This project should be able to be run through all of the steps outlined here.

4. If you haven't already, run `make bus-wrap-setup` (you only need to do this once).

5. Navigate to `verilog/rtl/team_projects/team_##/team_##.yml`
This file contains configuration information that our targets will use to generate top level and wrapper files.
You are allowed to use both the Logic Analyzer (LA) and Wishbone Master interface (WB_master) - see code snippet below. Each of these
will increase the perimeter of your design, but can add important and interesting functionality. Choose if you'll use these now. Once you've made your choice, run `make bus-wrap-generate`, which will modify the team wrapper file and create the Wishbone wrapper file. You can always change the YAML file later, but you will need to re-run `make nebula` (step #9 explains what this does).

```yaml
project_info:
  wb_master_enabled: False
  la_enabled: False
```

6. The `src` folder within `verilog/rtl/team_projects/team_##` is where you will save all your sub-module SystemVerilog files.<br>
**IMPORTANT:** To avoid problems during integration, please stick to the following sub-module naming syntax: `t##_<module_name>`. For example, if you are part of Team 01 and want to implement a clock divider module, you can name it `t01_clock_divider`. Do NOT name it just `clock_divider`! Additionally, your file names must match the module names. If your module name is `t02_counter`, then your file name must be `t02_counter.sv`.

7. Navigate to `verilog/rtl/team_projects/team_##/includes`. You must add the path of all the files that are part of your design here. Your design top level module (`team_##.sv`) and the wrapper files (`team_##_WB.v` and `team_##_Wrapper.sv`) are already included.

8. The `module_tests` folder within `verilog/dv/team_##` is where you will save all your sub-module and design top-level testbenches. Your testbench module name must follow this syntax: `<module_name>_tb`. For example, if the module you want to test is called `t01_clock_divider`, then the testbench name must be `t01_clock_divider_tb`. Similar to source code files, testbench file names must match the testbench module name. To simulate one of these testbenches run `make tb-module-team_##-<module_name>`. Example: `make tb-module-team_00-t00_flex_counter`.

9. Run `make nebula` to generate the NEBULA top level files - this will put your design within the `nebula` module, given it access to the Wishbone bus interconnect and the SRAM. Running this target calls a few Python scripts to combine all of the teams' designs together and write a few files. These scripts should NOT be changed, but if you're interested, you can see them in the `scripts` folder.

10. After you're done coding and testing yours design, you must verify that it works when we include it in the Caravel top-level. To do this, first run `make purdue-setup` to setup the testing environment. Then, to run a source-level simulation, run `make purdue-verify-team_##-rtl`. This will run the testbench located in `verilog/dv/team_##/team_##_tb.v` (ask your PM or any integration TA to explain what this testbench does and how to use it).

11. Once your design is passing your source-level (RTL) simulation, you will need to harden your team's macro (using OpenLane), place the macro within the top level User Project Wrapper, and harden the top level. This generates a gate-level netlist that will then be used for simulations. Edit the `config.json` file in `openlane/team_##` as you need and run `make team_##` to harden your design - this will take between a few minutes to an hour, depending on your design complexity. Then, manually place your design within `openlane/user_project_wrapper/macro.cfg` (follow the example of Team 00). Run `make user_project_wrapper` to harden the top level. This will take a while (at least an hour).

12. Run `make purdue-verify-team_##-gl` to run a gate-level simulation. This will take a while, but should produce the same results as your source simulation. If the results match, you are good to begin submitting your design.

13. There is a GitHub action that will identify some conflicts that we have had in the past. These are primarily naming conventions and you can see the results if you click on the actions tab on the web version of GitHub. To be approved for the final chip, you must pass each of these checks. If you find a bug, please feel free to report it.

14. Once your simulations are good and you are passing the GitHub action, you can create a **Pull Request** with your changes. Please do this to a branch on your repository other than main. If not, you will be asked to resubmit. If you need help with this, feel free to ask your PM.

## Additional (Useful) Targets
* `make cram_team_##` - Prototypes your design on the iCE40 FPGA. You can find the FPGA top level wrapper file here: `verilog/rtl/team_projects/team_##/team_##_fpga_top.sv`
* `make gdsview_team_##_klayout` - This will open a visualizer of your design's GDS layout using KLayout.
* `make sv2v_team_##` - Our open-source tools don't fully support SystemVerilog syntax and structures. `sv2v` is a great tool that allows you to convert your SystemVerilog code to Verilog code and make it compatible with all tools. If you run into a compilation error due to SystemVerilog syntax, feel free to use `sv2v`, but ask your PM if you have questions.
* `make assemble_team_##` - Converts RISC-V assembly into a HEX memory file and creates a C header file. These can be used for RTL simulations or other sub-module tesbenches. You must create an assembly file called `team_##_cpu.asm` under `verilog/dv/team_##` before using the target.
