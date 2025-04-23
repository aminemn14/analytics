-- 1. Ajout de la colonne visit_id (nullable pour le moment)
ALTER TABLE `website_event`
  ADD COLUMN `visit_id` VARCHAR(36) NULL;

-- 2. Remplissage de visit_id : une même UUID() par session & plage horaire
UPDATE `website_event` AS we
JOIN (
    SELECT
      session_id,
      DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00') AS visit_time,
      UUID() AS uuid
    FROM `website_event`
    GROUP BY
      session_id,
      DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00')
) AS grp
  ON we.session_id = grp.session_id
  AND DATE_FORMAT(we.created_at, '%Y-%m-%d %H:00:00') = grp.visit_time
SET we.visit_id = grp.uuid
WHERE we.visit_id IS NULL;

-- 3. On rend la colonne non-nullable
ALTER TABLE `website_event`
  MODIFY COLUMN `visit_id` VARCHAR(36) NOT NULL;

-- 4. Création des index
CREATE INDEX `website_event_visit_id_idx`
  ON `website_event`(`visit_id`);

CREATE INDEX `website_event_website_id_visit_id_created_at_idx`
  ON `website_event`(`website_id`, `visit_id`, `created_at`);