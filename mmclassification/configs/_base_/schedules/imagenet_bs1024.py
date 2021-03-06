# optimizer
optimizer = dict(type='SGD', lr=0.4, momentum=0.9, weight_decay=0.0001)
optimizer_config = dict(grad_clip=None)
# learning policy
lr_config = dict(policy='step', step=[30, 60, 90])
total_epochs = 100
