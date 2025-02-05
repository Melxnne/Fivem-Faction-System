INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_sample', 'Sample', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_sample', 'Sample', 1)
;

INSERT INTO `datastore_data` (`id`, `name`, `owner`, `data`) VALUES
(5, 'society_sample', NULL, '{\"dressing\":[]}'),

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_sample', 'Sample', 1)
;

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES 
    ('sample', 'Sample', 1)
;


INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`) VALUES
    ('sample', 0, 'member', 'Member', 500),
	('sample', 1, 'boss', 'Leaderschaft', 500),
	('sample', 2, 'boss', 'Boss', 500)
;