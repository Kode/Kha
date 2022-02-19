let project = new Project('Empty');

if (platform !== 'empty') {
	project.addParameter('-dce full');
}

project.addSources('Sources');

resolve(project);
