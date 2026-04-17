"use client"

import dynamic from "next/dynamic"
import { Loader2 } from "lucide-react"
import { createContext, useContext, useEffect, useRef, useState, useCallback } from "react"

interface ChartDimensions {
  width: number
  height: number
}

const ChartDimensionsContext = createContext<ChartDimensions>({ width: 0, height: 0 })

/**
 * Hook to get chart dimensions from the SafeChart parent.
 */
export function useChartDimensions() {
  return useContext(ChartDimensionsContext)
}

/**
 * Inner component that measures its own container and only renders children
 * once it has real, positive dimensions. This completely avoids the
 * ResponsiveContainer width(-1)/height(-1) warning.
 */
const SafeChartInner = ({ children }: { children: React.ReactNode }) => {
  const containerRef = useRef<HTMLDivElement>(null)
  const [dimensions, setDimensions] = useState<ChartDimensions | null>(null)

  const measure = useCallback(() => {
    if (containerRef.current) {
      const { width, height } = containerRef.current.getBoundingClientRect()
      if (width > 0 && height > 0) {
        setDimensions((prev) => {
          if (prev && prev.width === Math.floor(width) && prev.height === Math.floor(height)) {
            return prev // no change, avoid re-render
          }
          return { width: Math.floor(width), height: Math.floor(height) }
        })
      }
    }
  }, [])

  useEffect(() => {
    const el = containerRef.current
    if (!el) return

    // Initial measurement after a frame so the browser has laid out the element
    const raf = requestAnimationFrame(() => {
      measure()
    })

    // Watch for resizes
    const observer = new ResizeObserver(() => {
      measure()
    })
    observer.observe(el)

    return () => {
      cancelAnimationFrame(raf)
      observer.disconnect()
    }
  }, [measure])

  return (
    <div ref={containerRef} className="w-full h-full">
      {dimensions ? (
        <ChartDimensionsContext.Provider value={dimensions}>
          {children}
        </ChartDimensionsContext.Provider>
      ) : (
        <div className="w-full h-full flex items-center justify-center">
          <Loader2 className="w-6 h-6 animate-spin text-blue-600 opacity-20" />
        </div>
      )}
    </div>
  )
}

/**
 * A safe wrapper for Recharts components to prevent SSR dimension warnings.
 * Uses Next.js dynamic import with ssr: false and measures the container
 * with ResizeObserver before rendering charts.
 */
const SafeChart = dynamic(() => Promise.resolve(SafeChartInner), {
  ssr: false,
  loading: () => (
    <div className="w-full h-full flex items-center justify-center">
      <Loader2 className="w-6 h-6 animate-spin text-blue-600 opacity-20" />
    </div>
  )
})

export default SafeChart
