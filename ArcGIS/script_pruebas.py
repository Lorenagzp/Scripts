# -*- coding: utf-8 -*-
# ---------------------------------------------------------------------------
# script_pruebas.py
# Created on: 2014-06-07 16:59:26.00000
#   (generated by ArcGIS/ModelBuilder)
# Usage: script_pruebas <bf_Lx_2> <bf_Lx_1> <Grid> <L_Stats_table> <Raster> <Folder_tablas> 
# Description: 
# ---------------------------------------------------------------------------

# Import arcpy module
import arcpy

# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")

# Load required toolboxes
arcpy.ImportToolbox("Model Functions")

# Script arguments
bf_Lx_2 = arcpy.GetParameterAsText(0)
if bf_Lx_2 == '#' or not bf_Lx_2:
    bf_Lx_2 = "140117\\H140117_EYTBWMEL_bf_L3" # provide a default value if unspecified

bf_Lx_1 = arcpy.GetParameterAsText(1)
if bf_Lx_1 == '#' or not bf_Lx_1:
    bf_Lx_1 = "140117\\H140117_EYTBWEH_bf_L3" # provide a default value if unspecified

Grid = arcpy.GetParameterAsText(2)
if Grid == '#' or not Grid:
    Grid = "H140117_BW" # provide a default value if unspecified

L_Stats_table = arcpy.GetParameterAsText(3)
if L_Stats_table == '#' or not L_Stats_table:
    L_Stats_table = "D:\\AB2013-2014\\Bread_wheat\\data\\140117\\L3\\b1" # provide a default value if unspecified

Raster = arcpy.GetParameterAsText(4)
if Raster == '#' or not Raster:
    Raster = "E:\\140117\\140117H\\ortho\\140117_3_810.bsq" # provide a default value if unspecified

Folder_tablas = arcpy.GetParameterAsText(5)

# Local variables:
BW_AB_join_result = L_Stats_table
BW_AB_selection_result = BW_AB_join_result
BW_AB_calculateField_result = BW_AB_selection_result
BW_AB_remove_join_result = BW_AB_calculateField_result
B = L_Stats_table
path_table = L_Stats_table
L_merge = bf_Lx_2
Zone_field_and_join_Field = "Name"
grid_name = Grid
Field_Name_Calculate_field = "%grid_name%.%B%"
Expression_Calculate_field = "[%B%:Mean]"
Expression_Select_layer = "\"%B%:Mean\" IS NOT NULL"

# Process: Merge
arcpy.Merge_management("140117\\H140117_EYTBWMEL_bf_L3;140117\\H140117_EYTBWEH_bf_L3", L_merge, "Name \"Name\" true true false 254 Text 0 0 ,First,#,140117\\H140117_EYTBWMEL_bf_L3,Name,-1,-1,140117\\H140117_EYTBWEH_bf_L3,Name,-1,-1;environm \"environm\" true true false 20 Text 0 0 ,First,#,140117\\H140117_EYTBWMEL_bf_L3,environm,-1,-1")

# Process: Zonal Statistics as Table
arcpy.gp.ZonalStatisticsAsTable_sa(L_merge, Zone_field_and_join_Field, Raster, L_Stats_table, "DATA", "MEAN")

# Process: Add Join
arcpy.AddJoin_management(Grid, Zone_field_and_join_Field, L_Stats_table, Zone_field_and_join_Field, "KEEP_ALL")

# Process: parse_table_name
arcpy.ParsePath_mb(L_Stats_table, "NAME")

# Process: Parse_grid_name
arcpy.ParsePath_mb(Grid, "NAME")

# Process: Select Layer By Attribute
arcpy.SelectLayerByAttribute_management(BW_AB_join_result, "NEW_SELECTION", Expression_Select_layer)

# Process: Calculate Field
arcpy.CalculateField_management(BW_AB_selection_result, Field_Name_Calculate_field, Expression_Calculate_field, "VB", "")

# Process: Remove Join
arcpy.RemoveJoin_management(BW_AB_calculateField_result, "")

# Process: parse_table_path
arcpy.ParsePath_mb(L_Stats_table, "PATH")

