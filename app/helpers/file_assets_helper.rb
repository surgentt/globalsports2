module FileAssetsHelper

  def byte_count_to_string(byte_count, range=2)
    out = []

    if byte_count
      s = byte_count.to_i
      
      # m = (s / 1024).to_i
      # b = s - (m*1024)

      k = (s / 1024).to_i
      b = s - (k*1024)

      m = (k / 1024).to_i
      k = k - (m*1024)


      g = (m / 1024).to_i
      m = m - (g*1024)


      out << "#{g}g" if g > 0

      out << "#{m}m" if m > 0

      out << "#{k}k" if k > 0

      out << "#{b}b"
    end
    
    out[0,range].join(' ')
  end


  def time_span_to_string(start_time, end_time, range=2)
    out = []

    if start_time && end_time
      t = end_time - start_time

      m = (t / 60).to_i
      s = t.to_i - (m*60)

      h = (m / 60).to_i
      m = m.to_i - (h*60)

      out << "#{h}h " if h > 0

      out << "#{m}m " if m > 0

      out << "#{s}s"
    end

    out[0,range].join(' ')
  end



end
