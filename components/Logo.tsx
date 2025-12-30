interface LogoProps {
  className?: string
  showText?: boolean
  textClassName?: string
}

export default function Logo({ className = "w-12 h-12", showText = false, textClassName = "" }: LogoProps) {
  // Use transparent version for both header and footer
  const iconSrc = '/favicon_128_same_bag_transparent.ico'
  
  // More offset for footer
  const marginTop = textClassName.includes('text-white') ? '-40px' : '-25px'
  
  return (
    <div className={`flex items-center gap-3 ${showText ? 'flex-row' : 'flex-col'}`} style={{ marginTop }}>
      <div className={`${className} relative flex-shrink-0 flex items-center justify-center self-center`}>
        <img
          src={iconSrc}
          alt="TamiGoods Logo"
          className="w-full h-full object-contain"
          style={{
            imageRendering: 'auto',
            WebkitImageRendering: 'auto',
            display: 'block',
            verticalAlign: 'middle',
          }}
        />
      </div>

      {showText && (
        <div className={`flex items-center self-center ${textClassName}`} style={{ fontFamily: 'system-ui, -apple-system, sans-serif', lineHeight: '1.2' }}>
          <span 
            className={`text-lg font-semibold ${textClassName.includes('text-white') ? 'text-cyan-400' : 'text-cyan-500'}`} 
            style={{ 
              letterSpacing: '-0.3px',
              lineHeight: '1.2',
            }}
          >
            Tami
          </span>
          <span 
            className={`text-lg font-semibold ${textClassName.includes('text-white') ? 'text-orange-400' : 'text-[#FB923C]'}`} 
            style={{ 
              letterSpacing: '-0.3px',
              lineHeight: '1.2',
            }}
          >
            Goods
          </span>
        </div>
      )}
    </div>
  )
}
