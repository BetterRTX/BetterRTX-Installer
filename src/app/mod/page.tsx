"use client";
import { useEffect, useState } from "react";
import { Tab } from "@headlessui/react";
import { useMcPack } from "@/hooks/useMcPack";
import type JSZip from "jszip";

export default function Page() {
  const { openPack } = useMcPack();

  const [contents, setContents] = useState<string[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    if (loading) {
      openPack()
        .then((res) => {
          setContents(res);
        })
        .catch((err) => {
          setErrorMessage((err as Error).toString());
        })
        .finally(() => {
          setLoading(false);
        });
    }
  }, [loading, openPack]);

  return (
    <main className="flex min-h-screen min-w-96 flex-col">
      <div>
        {loading ? (
          <p>Opening...</p>
        ) : (
          <button type="button" onClick={() => setLoading(true)}>
            Open
          </button>
        )}
        {errorMessage && <p className="error-message">{errorMessage}</p>}
        {contents && (
          <Tab.Group>
            <Tab.List></Tab.List>
            <Tab.Panels>
              <Tab.Panel>
                <p>Tab 1</p>
                <pre>
                  <code>{JSON.stringify(contents, null, 2)}</code>
                </pre>
              </Tab.Panel>
            </Tab.Panels>
          </Tab.Group>
        )}
      </div>
    </main>
  );
}
