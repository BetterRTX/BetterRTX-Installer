import React, { useRef, useEffect, useCallback } from "react";
import { useTranslation } from "react-i18next";
import { ChevronDown } from "lucide-react";
import { cx } from "classix";

interface ConsolePanelProps {
  isExpanded: boolean;
  onToggle: (isExpanded: boolean) => void;
  output?: string[];
  onClear?: () => void;
}

export const ConsolePanel: React.FC<ConsolePanelProps> = ({
  isExpanded,
  onToggle,
  output = [],
  onClear,
}) => {
  const { t } = useTranslation();
  const outputRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when new output is added
  useEffect(() => {
    if (outputRef.current) {
      outputRef.current.scrollTop = outputRef.current.scrollHeight;
    }
  }, [output]);

  const handleToggle = useCallback((): void => {
    onToggle(!isExpanded);
  }, [isExpanded, onToggle]);

  const handleClear = useCallback((): void => {
    onClear?.();
  }, [onClear]);

  return (
    <div className="console-container">
      <div
        className="console-header flex justify-between items-center px-4 py-3 cursor-pointer select-none bg-app-panel border-app-border"
        onClick={handleToggle}
      >
        <h3 className="m-0 text-sm font-semibold text-app-fg">
          {t("console_output")}
        </h3>
        <span className="console-arrow transition-transform duration-200">
          <ChevronDown 
            size={16} 
            strokeWidth={2} 
            className={cx(
              "transition-transform duration-200",
              isExpanded && "rotate-180"
            )}
          />
        </span>
      </div>

      <div
        className={cx(
          "console-panel border overflow-hidden transition-all duration-300 bg-app-bg border-app-border",
          isExpanded ? "console-panel--expanded" : "console-panel--collapsed"
        )}
      >
        <div
          ref={outputRef}
          className="console-output"
        >
          {output.length > 0 ? output.join("\n") : "No output yet..."}

          <button
            className={cx(
              "console-clear-btn fixed left-auto bottom-2 right-6 px-3 py-1 text-xs border cursor-pointer hover:bg-opacity-80 transition-colors bg-app-panel border-app-border text-app-fg",
              isExpanded ? "block" : "hidden"
            )}
            onClick={handleClear}
          >
            Clear
          </button>
        </div>
      </div>
    </div>
  );
};
