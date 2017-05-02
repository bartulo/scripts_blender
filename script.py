import bpy
import bmesh
from mathutils import Vector

scale=8
lat=[1,0,-1]
offset=scale*0.975
strength = 1
mid_level = 0.5

for i in range(1,4):
	for n in range(1,4):
		file_name = 'mdt_%s_%s.tif' % (i,n)
		bpy.context.scene.cursor_location = Vector((offset*(-lat[n-1]),offset*lat[i-1],0))
		bpy.ops.import_image.to_plane(files=[{'name':file_name}], directory='/media/forex/disco/ustes/BRUTOS/8k')
		bpy.ops.transform.resize(value=(scale,scale,scale))
		bpy.ops.object.mode_set(mode = 'EDIT')
		bpy.ops.mesh.subdivide(number_cuts=99)
		bpy.ops.mesh.subdivide(number_cuts=3)
		bpy.ops.object.mode_set(mode = 'OBJECT')
		bpy.ops.object.modifier_add(type='DISPLACE')
		bpy.data.objects['mdt_%s_%s' % (i,n)].modifiers['Displace'].texture = bpy.data.textures['mdt_%s_%s' % (i,n)]
		bpy.data.objects['mdt_%s_%s' % (i,n)].modifiers['Displace'].texture_coords = 'UV'
		bpy.data.objects['mdt_%s_%s' % (i,n)].modifiers['Displace'].strength = strength
		bpy.data.objects['mdt_%s_%s' % (i,n)].modifiers['Displace'].mid_level = mid_level
		bpy.ops.object.shade_smooth()
		bpy.ops.object.mode_set(mode = 'EDIT')
		obj = bpy.context.object
		me = obj.data
		bm = bmesh.from_edit_mesh(me)
		vertices = [e for e in bm.verts]
		for vert in vertices:
			if vert.is_boundary == True:
				vert.select=True
			else:
				vert.select = False

		bpy.ops.mesh.delete(type='VERT')
		bpy.ops.object.mode_set(mode = 'OBJECT')

bpy.data.scenes['Scene'].render.engine = 'CYCLES'

for i in range(1,4):
	for n in range(1,4):
		img_path = ('/media/forex/disco/ustes/BRUTOS/8k/pnoa_%s_%s.jpg' % (i,n))
		img = bpy.data.images.load(img_path)
		mat = bpy.data.materials['mdt_%s_%s' % (i,n)]
		mat.use_nodes = True
		nodes = mat.node_tree.nodes
		node_texture = nodes.new(type='ShaderNodeTexImage')
		node_texture.image = img
		links = mat.node_tree.links
		link = links.new(node_texture.outputs[0], nodes.get("Diffuse BSDF").inputs[0])
