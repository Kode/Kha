let project = new Project('Empty');

project.addParameter('-dce full');

project.addSources('Sources');

resolve(project);
