/*
    rpt.v_dna_by_staff_group: per financial quarter and staff group, the
    delegates due (outcome A or D), the DNAs, the DNA rate as a percentage,
    and its change in percentage points since the group's previous quarter.
    The staff group is the one held at booking, from rpt.v_participation.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW rpt.v_dna_by_staff_group
AS
WITH quarterly AS
(
    SELECT
        dd.fy_label,
        dd.fy_quarter,
        dd.fy_quarter_label,
        p.staff_group_code,
        p.staff_group,
        COUNT(*)                                              AS delegates_due,
        SUM(CASE WHEN p.outcome_code = 'D' THEN 1 ELSE 0 END) AS dnas,
        100.0 * SUM(CASE WHEN p.outcome_code = 'D' THEN 1 ELSE 0 END) / COUNT(*) AS dna_rate
    FROM rpt.v_participation AS p
    JOIN rpt.dim_date AS dd ON dd.date_key = p.date_key
    WHERE p.role_code = 'DEL'
      AND p.outcome_code IN ('A', 'D')
    GROUP BY dd.fy_label, dd.fy_quarter, dd.fy_quarter_label, p.staff_group_code, p.staff_group
)
SELECT
    fy_quarter_label,
    staff_group_code,
    staff_group,
    delegates_due,
    dnas,
    CAST(dna_rate AS decimal(5, 1)) AS dna_rate_pct,
    -- LAG reads the same staff group's previous quarter; it is empty for the first one.
    CAST(dna_rate - LAG(dna_rate) OVER (PARTITION BY staff_group_code ORDER BY fy_label, fy_quarter)
         AS decimal(5, 1)) AS dna_rate_change_pts
FROM quarterly;
GO
