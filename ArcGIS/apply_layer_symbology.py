# Import modules
import arcpy

#Get the current Map Document
mxd = arcpy.mapping.MapDocument("CURRENT")

# Script arguments
Template_Layer = arcpy.GetParameterAsText(0)
Layers_to_Symbolize = arcpy.GetParameterAsText(1)

# Process: Apply Symbology From Layer
for UpdateLayer in Layers_to_Symbolize:
	if UpdateLayer.visible == True:
    	arcpy.AddMessage("Updating: " + UpdateLayer)
    	arcpy.ApplySymbologyFromLayer_management(UpdateLayer,Template_Layer)

# Refresh the Table of Contents to reflect the change
arcpy.RefreshTOC()

#Delete the MXD from memory
del mxd