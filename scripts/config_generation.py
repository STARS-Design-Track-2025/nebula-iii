import os
import glob

def find_root_directory(start_path):
    # Check if running in GitHub Actions
    github_workspace = os.getenv("GITHUB_WORKSPACE")
    if github_workspace:
        return github_workspace

    # Fallback to local method
    current_path = os.path.abspath(os.path.dirname(__file__))
    while current_path != os.path.dirname(current_path):
        if os.path.isdir(os.path.join(current_path, '.git')):
            return current_path
        current_path = os.path.dirname(current_path)
    print("Project directory not found")
    return None  # Return None if project directory is not found

def get_teams(root_directory):
    team_folders = glob.glob(root_directory + "/verilog/rtl/team_projects/*")
    return [os.path.basename(team_folder) for team_folder in team_folders]


def main():
    
    # Find the project directory
    root_directory = find_root_directory(os.getcwd())
    
    teams = get_teams(root_directory)
    print(f"Generating Config with {len(teams)-1} teams")
    
    # Specify the file to create
    output_file = root_directory + "/openlane/user_project_wrapper/config.json"

    # Write to the file
    with open(output_file, 'w') as f:
        f.write(\

"""
{
    "DESIGN_NAME": "user_project_wrapper",
    "VERILOG_FILES": [
        "dir::../../verilog/rtl/wb_wrapper.vh",
        "dir::../../verilog/rtl/sram/sram_WB_Wrapper.sv",
        "dir::../../verilog/rtl/gpio_control/gpio_control_WB.sv",
        "dir::../../verilog/rtl/gpio_control/gpio_control_Wrapper.v",
        "dir::../../verilog/rtl/gpio_control/gpio_control.sv",
        "dir::../../verilog/rtl/la_control/la_control_WB.v",
        "dir::../../verilog/rtl/la_control/la_control_Wrapper.v",
        "dir::../../verilog/rtl/la_control/la_control.sv",
        "dir::../../verilog/rtl/wishbone_manager/wishbone_manager.sv",
        "dir::../../verilog/rtl/wishbone_interconnect/wishbone_arbitrator.sv",
        "dir::../../verilog/rtl/wishbone_interconnect/wishbone_decoder.sv",
        "dir::../../verilog/rtl/defines.v",
        "dir::../../verilog/rtl/nebula.v",
        "dir::../../verilog/rtl/wb_interconnect.sv",
"""\
)  
            
        for team in teams:
            f.write(\
f"""      
        "dir::../../verilog/rtl/team_projects/{team}/{team}_WB.v",
        "dir::../../verilog/rtl/team_projects/{team}/{team}_Wrapper.sv",  
"""\
)
                
        f.write(\
"""                
        "dir::../../verilog/rtl/user_project_wrapper.v"
    ],
    "ROUTING_CORES": 6,
    "CLOCK_PERIOD": 25,
    "CLOCK_PORT": "wb_clk_i",
    "CLOCK_NET": "wb_clk_i",
    "ERROR_ON_KLAYOUT_DRC": false,
    "FP_PDN_MACRO_HOOKS": [
"""\
)
        for team in teams:
            f.write(\
f"""      
        "mprj.{team}_Wrapper.{team}_WB.instance_to_wrap vccd1 vssd1 vccd1 vssd1",
"""\
)
                
    
        f.write(\
"""                
        "mprj.sram.sram_inst vccd1 vssd1 vccd1 vssd1"
    ],
    "MACRO_PLACEMENT_CFG": "dir::macro.cfg",
    "MAGIC_DEF_LABELS": 0,
    "VERILOG_FILES_BLACKBOX": [
"""\
)
            
        for team in teams:
            f.write(\
f"""      
        "dir::../../verilog/gl/{team}.v",
"""\
)
                

        f.write(\
"""                
        "dir::../../verilog/rtl/sram/sky130_sram_8kbyte_1r1w_32x2048_8.v"
    ],
    "EXTRA_LEFS": [
"""\
)
            
        for team in teams:
            f.write(\
f"""      
        "dir::../../lef/{team}.lef",
"""\
)
                

        f.write(\
"""                
        "dir::../../lef/sky130_sram_8kbyte_1r1w_32x2048_8.lef"
    ],
    "EXTRA_GDS_FILES": [
"""\
)
            
        for team in teams:
            f.write(\
f"""      
        "dir::../../gds/{team}.gds",
"""\
)
                

        f.write(\
"""                
        "dir::../../gds/sky130_sram_8kbyte_1r1w_32x2048_8.gds"
    ],
    "EXTRA_LIBS": [
"""\
)        
            
        for team in teams:
            f.write(\
f"""      
        "dir::../../lib/{team}.lib",
"""\
)
                
        f.write(\
"""     
        "dir::../../lib/sky130_sram_8kbyte_1r1w_32x2048_8_TT_1p8V_25C.lib"
    ],
    "EXTRA_SPEFS": [
"""\
)  
        for i, team in enumerate(teams):
            comma = "," if i < len(teams) - 1 else ""
            f.write(\
f"""      
        "{team}", 
        "dir::../../spef/multicorner/{team}.min.spef", 
        "dir::../../spef/multicorner/{team}.nom.spef", 
        "dir::../../spef/multicorner/{team}.max.spef"{comma}
"""\
)
                
        f.write(\
"""                
    ],
    "BASE_SDC_FILE": "dir::base_user_project_wrapper.sdc",
    "IO_SYNC": 0,
    "MAX_TRANSITION_CONSTRAINT": 1.5,
    "RUN_LINTER": 0,
    "QUIT_ON_SYNTH_CHECKS": 0,
    "FP_PDN_CHECK_NODES": 1,

    "//": "Added to skip DRC, because of SRAM (will remove later)",
    "RUN_KLAYOUT_DRC": 0,
    "RUN_MAGIC_DRC": 0,
    "MAGIC_DRC_USE_GDS": 0,
    "QUIT_ON_MAGIC_DRC": 0,

    "SYNTH_ELABORATE_ONLY": 0,
    "SYNTH_CLOCK_UNCERTAINTY": 0.2,
    "PL_RESIZER_HOLD_SLACK_MARGIN": 1.0,
    "GLB_RESIZER_HOLD_SLACK_MARGIN": 1.0,
    "PL_RANDOM_GLB_PLACEMENT": 1,
    "PL_RESIZER_DESIGN_OPTIMIZATIONS": 1,
    "PL_RESIZER_TIMING_OPTIMIZATIONS": 1,
    "PL_OPENPHYSYN_OPTIMIZATIONS": 1,
    "GLB_RESIZER_DESIGN_OPTIMIZATIONS": 1,
    "GLB_RESIZER_TIMING_OPTIMIZATIONS": 1,
    "PL_RESIZER_BUFFER_INPUT_PORTS": 1,
    "CTS_TOLERANCE": 50,
    "GPL_CELL_PADDING": 80,
    "DPL_CELL_PADDING": 20,
    "FP_PDN_ENABLE_RAILS": 1,
    "GRT_REPAIR_ANTENNAS": 1,
    "RUN_FILL_INSERTION": 1,
    "RUN_TAP_DECAP_INSERTION": 1,
    "RUN_HEURISTIC_DIODE_INSERTION": true,
    "FP_PDN_VPITCH": 180,
    "FP_PDN_HPITCH": 180,
    "RUN_CTS": 1,
    "FP_PDN_VOFFSET": 5,
    "FP_PDN_HOFFSET": 5,
    "MAGIC_ZEROIZE_ORIGIN": 0,
    "FP_SIZING": "absolute",
    "RUN_CVC": 0,
    "UNIT": 2.4,
    "FP_IO_VEXTEND": "expr::2 * $UNIT",
    "FP_IO_HEXTEND": "expr::2 * $UNIT",
    "FP_IO_VLENGTH": "expr::$UNIT",
    "FP_IO_HLENGTH": "expr::$UNIT",
    "FP_IO_VTHICKNESS_MULT": 4,
    "FP_IO_HTHICKNESS_MULT": 4,
    "FP_PDN_CORE_RING": 1,
    "FP_PDN_CORE_RING_VWIDTH": 3.1,
    "FP_PDN_CORE_RING_HWIDTH": 3.1,
    "FP_PDN_CORE_RING_VOFFSET": 12.45,
    "FP_PDN_CORE_RING_HOFFSET": 12.45,
    "FP_PDN_CORE_RING_VSPACING": 1.7,
    "FP_PDN_CORE_RING_HSPACING": 1.7,
    "FP_PDN_VWIDTH": 3.1,
    "FP_PDN_HWIDTH": 3.1,
    "FP_PDN_VSPACING": "expr::(5 * $FP_PDN_CORE_RING_VWIDTH)",
    "FP_PDN_HSPACING": "expr::(5 * $FP_PDN_CORE_RING_HWIDTH)",
    "ERROR_ON_MAGIC_DRC": 0,
    "VDD_NETS": [
        "vccd1",
        "vccd2",
        "vdda1",
        "vdda2"
    ],
    "GND_NETS": [
        "vssd1",
        "vssd2",
        "vssa1",
        "vssa2"
    ],
    "SYNTH_USE_PG_PINS_DEFINES": "USE_POWER_PINS",
    "pdk::sky130*": {
        "PL_TARGET_DENSITY": 0.25,
        "RT_MAX_LAYER": "met4",
        "DIE_AREA": "0 0 2920 3520",
        "FP_DEF_TEMPLATE": "dir::fixed_dont_change/user_project_wrapper.def"
    }
}

"""\
)  
        
    print("Done writing openlane config for user_project_wrapper")

if __name__ == "__main__":
    main()