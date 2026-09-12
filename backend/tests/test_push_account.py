import base64
import json
import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.services.firebase_credentials import load_service_account_info, token_is_unregistered


class LoadServiceAccountInfoTest(unittest.TestCase):
    def test_empty(self) -> None:
        self.assertIsNone(load_service_account_info(""))
        self.assertIsNone(load_service_account_info("   "))

    def test_raw_json(self) -> None:
        info = load_service_account_info('{"type":"service_account","project_id":"enfold"}')
        self.assertEqual(info["project_id"], "enfold")

    def test_file_path(self) -> None:
        payload = {"type": "service_account", "project_id": "from-file"}
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as handle:
            json.dump(payload, handle)
            path = handle.name
        try:
            info = load_service_account_info(path)
            self.assertEqual(info["project_id"], "from-file")
        finally:
            Path(path).unlink(missing_ok=True)

    def test_base64(self) -> None:
        raw = json.dumps({"type": "service_account", "project_id": "b64"})
        encoded = base64.b64encode(raw.encode("utf-8")).decode("ascii")
        info = load_service_account_info(encoded)
        self.assertEqual(info["project_id"], "b64")


class UnregisteredTokenTest(unittest.TestCase):
    def test_404(self) -> None:
        self.assertTrue(token_is_unregistered(404, {}))

    def test_unregistered_status(self) -> None:
        self.assertTrue(
            token_is_unregistered(400, {"error": {"status": "UNREGISTERED"}})
        )

    def test_other_error_keeps_token(self) -> None:
        self.assertFalse(
            token_is_unregistered(500, {"error": {"status": "UNAVAILABLE"}})
        )


if __name__ == "__main__":
    unittest.main()
