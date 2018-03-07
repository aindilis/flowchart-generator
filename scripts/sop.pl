#!/usr/bin/perl -w

system "swipl -s /var/lib/myfrdcsa/codebases/minor/flowchart-generator/scripts/sop_loader.pl -g renderFlowChart";

# dot -Tpng /var/lib/myfrdcsa/codebases/minor/flowchart-generator/data-git/flp.dot -o /var/lib/myfrdcsa/codebases/minor/flowchart-generator/data-git/flp.png
# eog /var/lib/myfrdcsa/codebases/minor/flowchart-generator/data-git/flp.png

