import { useRef, useState } from "react";
import { formatFileSize } from "../lib/format";

type FileDropzoneProps = {
  label: string;
  hint: string;
  accept: string;
  file: File | null;
  disabled?: boolean;
  onFile: (file: File | null) => void;
};

export function FileDropzone({
  label,
  hint,
  accept,
  file,
  disabled = false,
  onFile,
}: FileDropzoneProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [dragOver, setDragOver] = useState(false);

  function pickFile(next: File | null) {
    onFile(next);
  }

  return (
    <div className="field">
      <span className="field-label">{label}</span>
      <div
        className={`dropzone ${dragOver ? "drag-over" : ""} ${file ? "has-file" : ""}`}
        onDragOver={(e) => {
          e.preventDefault();
          if (!disabled) {
            setDragOver(true);
          }
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={(e) => {
          e.preventDefault();
          setDragOver(false);
          if (disabled) {
            return;
          }
          const dropped = e.dataTransfer.files?.[0];
          if (dropped) {
            pickFile(dropped);
          }
        }}
        onClick={() => !disabled && inputRef.current?.click()}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            if (!disabled) {
              inputRef.current?.click();
            }
          }
        }}
        role="button"
        tabIndex={disabled ? -1 : 0}
      >
        <input
          ref={inputRef}
          type="file"
          accept={accept}
          className="dropzone-input"
          disabled={disabled}
          onChange={(e) => pickFile(e.target.files?.[0] ?? null)}
        />
        {file ? (
          <div className="dropzone-file">
            <strong>{file.name}</strong>
            <span>{formatFileSize(file.size)}</span>
            <button
              type="button"
              className="btn-ghost btn-sm"
              onClick={(e) => {
                e.stopPropagation();
                pickFile(null);
                if (inputRef.current) {
                  inputRef.current.value = "";
                }
              }}
            >
              Remove
            </button>
          </div>
        ) : (
          <div className="dropzone-empty">
            <span className="dropzone-icon">↑</span>
            <strong>Drop file here or click to browse</strong>
            <span>{hint}</span>
          </div>
        )}
      </div>
    </div>
  );
}

type MultiFileDropzoneProps = {
  label: string;
  hint: string;
  accept: string;
  files: File[];
  disabled?: boolean;
  startOrder?: number;
  onFiles: (files: File[]) => void;
};

export function MultiFileDropzone({
  label,
  hint,
  accept,
  files,
  disabled = false,
  startOrder = 1,
  onFiles,
}: MultiFileDropzoneProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [dragOver, setDragOver] = useState(false);

  function appendFiles(incoming: FileList | File[] | null) {
    if (!incoming) {
      return;
    }
    const next = Array.from(incoming);
    if (next.length === 0) {
      return;
    }
    onFiles([...files, ...next]);
  }

  function removeAt(index: number) {
    onFiles(files.filter((_, i) => i !== index));
  }

  function move(index: number, delta: number) {
    const target = index + delta;
    if (target < 0 || target >= files.length) {
      return;
    }
    const next = [...files];
    const [item] = next.splice(index, 1);
    next.splice(target, 0, item);
    onFiles(next);
  }

  return (
    <div className="field">
      <span className="field-label">{label}</span>
      <div
        className={`dropzone ${dragOver ? "drag-over" : ""} ${files.length ? "has-file" : ""}`}
        onDragOver={(e) => {
          e.preventDefault();
          if (!disabled) {
            setDragOver(true);
          }
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={(e) => {
          e.preventDefault();
          setDragOver(false);
          if (disabled) {
            return;
          }
          appendFiles(e.dataTransfer.files);
        }}
        onClick={() => !disabled && inputRef.current?.click()}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            if (!disabled) {
              inputRef.current?.click();
            }
          }
        }}
        role="button"
        tabIndex={disabled ? -1 : 0}
      >
        <input
          ref={inputRef}
          type="file"
          accept={accept}
          multiple
          className="dropzone-input"
          disabled={disabled}
          onChange={(e) => {
            appendFiles(e.target.files);
            if (inputRef.current) {
              inputRef.current.value = "";
            }
          }}
        />
        <div className="dropzone-empty">
          <span className="dropzone-icon">↑</span>
          <strong>
            {files.length
              ? "Add more files or click to browse"
              : "Drop multiple files here or click to browse"}
          </strong>
          <span>{hint}</span>
        </div>
      </div>

      {files.length > 0 ? (
        <ul className="bulk-file-list">
          {files.map((item, index) => (
            <li key={`${item.name}-${index}`} className="bulk-file-list__row">
              <span className="bulk-file-list__order">EP.{startOrder + index}</span>
              <span className="bulk-file-list__name" title={item.name}>
                {item.name}
              </span>
              <span className="bulk-file-list__size">
                {formatFileSize(item.size)}
              </span>
              <span className="bulk-file-list__actions">
                <button
                  type="button"
                  className="btn-ghost btn-sm"
                  disabled={disabled || index === 0}
                  onClick={() => move(index, -1)}
                  title="Move up"
                >
                  ↑
                </button>
                <button
                  type="button"
                  className="btn-ghost btn-sm"
                  disabled={disabled || index === files.length - 1}
                  onClick={() => move(index, 1)}
                  title="Move down"
                >
                  ↓
                </button>
                <button
                  type="button"
                  className="btn-ghost btn-sm"
                  disabled={disabled}
                  onClick={() => removeAt(index)}
                  title="Remove"
                >
                  ✕
                </button>
              </span>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  );
}
