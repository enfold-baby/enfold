import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.models import Family, User


class DeleteCascadeTest(unittest.TestCase):
    def test_parent_relationships_leave_the_cascade_to_the_database(self) -> None:
        # Deleting an account removes the user and, for the last member, the family.
        # Without passive deletes the ORM first blanks children.family_id and
        # family_memberships.user_id, which are NOT NULL, and the delete fails.
        for rel in (Family.children.property, Family.memberships.property, User.memberships.property):
            self.assertTrue(rel.passive_deletes, rel)
            self.assertIn("delete", rel.cascade, rel)


if __name__ == "__main__":
    unittest.main()
